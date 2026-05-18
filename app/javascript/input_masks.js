const NAV_KEYS = new Set([
  "Backspace",
  "Delete",
  "Tab",
  "Escape",
  "Enter",
  "ArrowLeft",
  "ArrowRight",
  "ArrowUp",
  "ArrowDown",
  "Home",
  "End"
])

const onlyDigits = (value, maxLength = null) => {
  let digits = value.replace(/\D/g, "")
  if (maxLength != null) digits = digits.slice(0, maxLength)
  return digits
}

const selectedDigitSpan = (input) => {
  const start = input.selectionStart ?? 0
  const end = input.selectionEnd ?? 0
  const before = onlyDigits(input.value.slice(0, start))
  const after = onlyDigits(input.value.slice(end))
  return { before, after, selected: onlyDigits(input.value.slice(start, end)).length }
}

const formatPhoneBr = (value) => {
  const digits = onlyDigits(value, 11)
  if (digits.length === 0) return ""
  if (digits.length === 1) return `(${digits}`
  if (digits.length === 2) return `(${digits})`
  if (digits.length <= 6) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`
  if (digits.length <= 10) {
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`
  }
  return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7, 11)}`
}

const phoneDigitCount = (value) => onlyDigits(value).length

const placeCursorAfterDigits = (input, digitCount) => {
  let position = 0
  let seen = 0
  const target = Math.max(0, digitCount)

  while (position < input.value.length && seen < target) {
    if (/\d/.test(input.value[position])) seen += 1
    position += 1
  }

  input.setSelectionRange(position, position)
}

const bindPhoneMask = (input) => {
  if (input.dataset.maskPhoneBound === "true") return
  input.dataset.maskPhoneBound = "true"
  input.setAttribute("inputmode", "tel")
  input.setAttribute("autocomplete", "tel")

  const applyDigits = (rawDigits, digitCursor) => {
    const digits = onlyDigits(rawDigits, 11)
    input.value = formatPhoneBr(digits)
    placeCursorAfterDigits(input, digitCursor ?? digits.length)
  }

  const syncFromValue = () => {
    const cursor = input.selectionStart ?? input.value.length
    const digitsBeforeCursor = onlyDigits(input.value.slice(0, cursor)).length
    applyDigits(input.value, digitsBeforeCursor)
  }

  input.addEventListener("beforeinput", (event) => {
    if (event.inputType === "insertText") {
      const char = event.data ?? ""
      if (!/^\d$/.test(char)) {
        event.preventDefault()
        return
      }

      event.preventDefault()
      const { before, after } = selectedDigitSpan(input)
      if (before.length + after.length >= 11) return

      applyDigits(before + char + after, before.length + 1)
      return
    }

    if (event.inputType === "insertFromPaste") {
      event.preventDefault()
      const { before, after } = selectedDigitSpan(input)
      const pasted = onlyDigits(event.clipboardData?.getData("text") ?? "")
      const merged = onlyDigits(before + pasted + after, 11)
      applyDigits(merged, before.length + pasted.length)
    }
  })

  input.addEventListener("input", () => {
    syncFromValue()
  })

  input.addEventListener("keydown", (event) => {
    if (NAV_KEYS.has(event.key) || event.ctrlKey || event.metaKey || event.altKey) return
    if (/^\d$/.test(event.key)) return
    if (event.key.length === 1) event.preventDefault()
  })

  if (input.value) syncFromValue()
}

const bindDigitsOnly = (input) => {
  if (input.dataset.digitsOnlyBound === "true") return
  input.dataset.digitsOnlyBound = "true"
  input.setAttribute("inputmode", "numeric")

  const max = input.dataset.digitsMax ? parseInt(input.dataset.digitsMax, 10) : null
  const min = input.dataset.digitsMin ? parseInt(input.dataset.digitsMin, 10) : null

  if (max != null) input.setAttribute("maxlength", String(max))

  const validate = () => {
    if (!input.value) {
      input.setCustomValidity("")
      return
    }
    const len = input.value.length
    if (min != null && len < min) {
      input.setCustomValidity(`Informe no mínimo ${min} dígitos.`)
    } else if (max != null && len > max) {
      input.setCustomValidity(`Informe no máximo ${max} dígitos.`)
    } else {
      input.setCustomValidity("")
    }
  }

  const apply = () => {
    const next = onlyDigits(input.value, max)
    if (input.value !== next) input.value = next
    validate()
  }

  input.addEventListener("keydown", (event) => {
    if (NAV_KEYS.has(event.key) || event.ctrlKey || event.metaKey || event.altKey) return
    if (!/^\d$/.test(event.key)) {
      event.preventDefault()
      return
    }

    if (max == null) return
    const { before, after, selected } = selectedDigitSpan(input)
    const nextLength = before.length + after.length - selected + 1
    if (nextLength > max) event.preventDefault()
  })

  input.addEventListener("paste", (event) => {
    event.preventDefault()
    const { before, after } = selectedDigitSpan(input)
    const pasted = onlyDigits(event.clipboardData.getData("text"))
    input.value = onlyDigits(before + pasted + after, max)
    validate()
  })

  input.addEventListener("input", apply)
  input.addEventListener("blur", validate)
  if (input.value) apply()
}

const formatDecimal = (value, maxInt, scale) => {
  let v = value.replace(/[^\d.,]/g, "").replace(",", ".")
  const parts = v.split(".")
  if (parts.length > 2) v = `${parts.shift()}.${parts.join("")}`

  let [intPart = "", decPart = ""] = v.split(".")
  if (maxInt != null) intPart = intPart.slice(0, maxInt)
  if (scale != null && decPart.length > scale) decPart = decPart.slice(0, scale)

  if (v.includes(".")) return decPart.length > 0 ? `${intPart}.${decPart}` : `${intPart}.`
  return intPart
}

const bindDecimalInput = (input) => {
  if (input.dataset.decimalBound === "true") return
  input.dataset.decimalBound = "true"
  input.setAttribute("inputmode", "decimal")

  const maxInt = input.dataset.decimalMaxInt ? parseInt(input.dataset.decimalMaxInt, 10) : 10
  const scale = input.dataset.decimalScale ? parseInt(input.dataset.decimalScale, 10) : 2
  const maxLength = maxInt + 1 + scale
  input.setAttribute("maxlength", String(maxLength))

  const apply = () => {
    input.value = formatDecimal(input.value, maxInt, scale)
  }

  input.addEventListener("keydown", (event) => {
    if (NAV_KEYS.has(event.key) || event.ctrlKey || event.metaKey || event.altKey) return
    if (!/^[\d.,]$/.test(event.key)) {
      event.preventDefault()
      return
    }

    const next = formatDecimal(
      input.value.slice(0, input.selectionStart ?? 0) +
        event.key +
        input.value.slice(input.selectionEnd ?? 0),
      maxInt,
      scale
    )
    if (next.length > maxLength) event.preventDefault()
  })

  input.addEventListener("paste", (event) => {
    event.preventDefault()
    const { before, after } = {
      before: input.value.slice(0, input.selectionStart ?? 0),
      after: input.value.slice(input.selectionEnd ?? 0)
    }
    input.value = formatDecimal(before + event.clipboardData.getData("text") + after, maxInt, scale)
  })

  input.addEventListener("input", apply)
  if (input.value) apply()
}

const bindInputMasksIn = (root = document) => {
  root.querySelectorAll("[data-mask-phone]").forEach(bindPhoneMask)
  root.querySelectorAll("[data-input-digits]").forEach(bindDigitsOnly)
  root.querySelectorAll("[data-input-decimal]").forEach(bindDecimalInput)
}

export { bindInputMasksIn }

export const initInputMasks = () => {
  bindInputMasksIn(document)

  if (document.documentElement.dataset.inputMasksFocusinBound === "true") return
  document.documentElement.dataset.inputMasksFocusinBound = "true"

  document.addEventListener(
    "focusin",
    (event) => {
      const target = event.target
      if (!(target instanceof HTMLInputElement)) return
      if (target.matches("[data-mask-phone]")) bindPhoneMask(target)
      if (target.matches("[data-input-digits]")) bindDigitsOnly(target)
      if (target.matches("[data-input-decimal]")) bindDecimalInput(target)
    },
    true
  )
}
