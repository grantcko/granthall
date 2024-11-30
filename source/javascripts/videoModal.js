// Bunny.net Video Player Reset on modal close Handler
console.log("imported");

export function resetBunnyVideoPlayerOnModalClose() {
  console.log("hifromresetbunnyvideoplayeronmodalclose");
  const videoModals = document.querySelectorAll('.modal');

  videoModals.forEach(modal => {
    modal.addEventListener('hidden.bs.modal', function() {
      const iframe = modal.querySelector('iframe.bunny-video-player');
      if (iframe) {
        const currentSrc = iframe.src;
        iframe.src = ''; // Remove source to force video stop
        // Restore src with autoplay set to false
        setTimeout(() => {
          iframe.src = currentSrc.replace('autoplay=true', 'autoplay=false');
        }, 100);
      }
    });
  });
}

export function manageVideoURLHash() {
  console.log("magangevideourlhash");
  // Open video modal if ID is in URL
  const videoId = window.location.hash.slice(1);
  if (videoId) {
    const targetModal = document.getElementById(`modal-${videoId}`);
    if (targetModal) {
      const modal = new bootstrap.Modal(targetModal);
      modal.show();
    }
  }

  // Update URL when modals open/close
  document.querySelectorAll('.modal').forEach(modal => {
    modal.addEventListener('show.bs.modal', event => {
      const videoId = modal.id.replace('modal-', '');
      window.history.pushState({}, '', `#${videoId}`);
    });

    modal.addEventListener('hidden.bs.modal', () => {
      window.history.pushState({}, '', window.location.pathname);
    });
  });
}
