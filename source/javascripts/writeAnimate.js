export function scrollTrigger(selector) {
  console.log('howdy');
  let els = document.querySelectorAll(selector);
  els = Array.from(els);

  let observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  });

  els.forEach(el => {
    observer.observe(el);
  });
}
