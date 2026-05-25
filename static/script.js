const chipsEl = document.getElementById('chips');
const counterEl = document.getElementById('counter');
const findBtn = document.getElementById('findBtn');
const progressEl = document.getElementById('progress');
const loaderEl = document.getElementById('loader');
const resultEl = document.getElementById('result');

const selected = new Set();

window.INGREDIENTS.forEach(item => {
  const chip = document.createElement('button');
  chip.className = 'chip';
  chip.innerText = `${item.emoji} ${item.label}`;
  chip.onclick = () => {
    selected.has(item.name) ? selected.delete(item.name) : selected.add(item.name);
    chip.classList.toggle('active');
    counterEl.innerText = selected.size;
  };
  chipsEl.appendChild(chip);
});

findBtn.onclick = async () => {
  resultEl.classList.add('hidden');
  loaderEl.classList.remove('hidden');
  progressEl.style.width = '15%';
  await new Promise(r => setTimeout(r, 350));
  progressEl.style.width = '55%';

  const res = await fetch('/api/recommend', {
    method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({ingredients: [...selected]})
  });
  const data = await res.json();

  progressEl.style.width = '100%';
  loaderEl.classList.add('hidden');
  resultEl.classList.remove('hidden');

  if (!res.ok) {
    resultEl.innerHTML = `<div class="glass"><h3>Błąd</h3><p>${data.error}</p></div>`;
    return;
  }

  const b = data.best;
  resultEl.innerHTML = `
  <article class="glass result-card">
    <div class="best">${b.name}</div>
    <div class="ring" style="--p:${b.match_percent * 3.6}deg"><span>${b.match_percent}%</span></div>
    <p><strong>Czas:</strong> ${b.prep_time} min | <strong>Trudność:</strong> ${b.difficulty}</p>
    <p>${data.reason}</p>
    <h4>Masz już:</h4><div class="list">${b.has.map(x=>`<span class="chip ok">${x}</span>`).join('')}</div>
    <h4>Brakuje:</h4><div class="list">${b.missing.map(x=>`<span class="chip bad">${x}</span>`).join('') || '<span class="chip ok">Nic 🎉</span>'}</div>
    <h4>Alternatywy:</h4>
    <div class="alt-grid">${data.alternatives.map((a,i)=>`<div class="alt" style="animation-delay:${i*120}ms">${a.name}<br><b>${a.match_percent}%</b></div>`).join('')}</div>
  </article>`;
};

(function grid() {
  const c = document.getElementById('bg-grid'), x = c.getContext('2d');
  let w,h,t=0; const rs=()=>{w=c.width=innerWidth;h=c.height=innerHeight}; rs(); addEventListener('resize',rs);
  (function a(){t+=.01;x.clearRect(0,0,w,h);for(let i=0;i<60;i++){const px=(i*47+t*90)%w;x.fillStyle='rgba(19,241,255,.35)';x.fillRect(px,(i*83)%h,2,2);}requestAnimationFrame(a)})();
})();
