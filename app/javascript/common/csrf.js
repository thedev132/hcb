export default function csrf() {
  return document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
}

export function csrfParam() {
  return document
    .querySelector('meta[name="csrf-param"]')
    .getAttribute('content')
}
