function changeCode(id) {
  const activeQRCode = document.querySelector(".qrCode--active");
  document.getElementById("downloadButton").innerText = "Download";
  if (activeQRCode) {
    activeQRCode.classList.remove("qrCode--active");
  }
  document.getElementById(`qrCode--${id}`).classList.add("qrCode--active");
}

function saveActiveQRCodeAsImage() {
  document.getElementById("downloadButton").innerText = "Downloading...";
  const activeQRCode = document.querySelector(".qrCode--active");
  if (!activeQRCode) {
    return;
  }
  html2canvas(activeQRCode, {
    scale: 4,
    backgroundColor: null,
    useCORS: true,
  }).then((canvas) => {
    const imageDataURL = canvas.toDataURL("image/png");
    const downloadLink = document.createElement("a");
    downloadLink.href = imageDataURL;
    downloadLink.download = "qr_code.png";
    downloadLink.click();
    document.getElementById("downloadButton").innerText = "Download";
  })
  .catch((error) => {
    console.error(error);
    document.getElementById("downloadButton").innerText = "Try Again";
  });
}
