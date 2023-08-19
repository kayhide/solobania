export function onEvent(event) {
  return (f) => () => {
    const listener = (e) => f(e)();
    window.document.addEventListener(event, listener);
    return listener;
  };
}

export function offEvent(event) {
  return (listener) => () => {
    window.document.removeEventListener(event, listener);
  };
}
