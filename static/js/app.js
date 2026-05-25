const quiz = document.getElementById('quiz');
const resultEl = document.getElementById('result');
const analysisEl = document.getElementById('analysis');
const progressEl = document.getElementById('progress');

let idx = 0;
const answers = {};

function renderQuestion() {
  const q = window.QUESTIONS[idx];
  progressEl.style.width = `${(idx / window.QUESTIONS.length) * 100}%`;
  quiz.innerHTML = `
    <div class="q-card glass">
      <h2>Pytanie ${idx + 1}/${window.QUESTIONS.length}</h2>
      <p>${q.text}</p>
      <div class="answers">
        <button onclick="selectAnswer(true)">Tak</button>
        <button onclick="selectAnswer(false)">Nie</button>
      </div>
    </div>`;
}

window.selectAnswer = (val) => {
  answers[window.QUESTIONS[idx].key] = val;
  idx += 1;
  if (idx < window.QUESTIONS.length) renderQuestion();
  else submitQuiz();
};

async function submitQuiz() {
  quiz.classList.add('hidden');
  analysisEl.classList.remove('hidden');
  await new Promise(r => setTimeout(r, 2200));
  const res = await fetch('/api/recommend', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ answers })
  });
  const data = await res.json();
  analysisEl.classList.add('hidden');

  if (!res.ok) {
    resultEl.classList.remove('hidden');
    resultEl.innerHTML = `<div class='result-card glass'><h2>Błąd</h2><p>${data.error}</p></div>`;
    return;
  }

  progressEl.style.width = '100%';
  resultEl.classList.remove('hidden');
  resultEl.innerHTML = `
    <div class="result-card glass">
      <div class="badge">🏆 ${data.language.toUpperCase()} (${data.match_percent}%)</div>
      <p>${data.reason}</p>
      <h3>3 powody wyboru:</h3>
      <ul>${data.reasons.map(r=>`<li>${r}</li>`).join('')}</ul>
      <h3>Alternatywy:</h3>
      <div class="alt-grid">${data.alternatives.map(a=>`<div class='alt'>${a.language}<br><strong>${a.match_percent}%</strong></div>`).join('')}</div>
      <canvas id="chart" height="120"></canvas>
      <button onclick="location.reload()">Zacznij ponownie</button>
    </div>`;

  const labels = data.ranking.map(x => x.language);
  const points = data.ranking.map(x => x.match_percent);
  new Chart(document.getElementById('chart'), {
    type: 'bar',
    data: { labels, datasets: [{ label: 'Dopasowanie %', data: points, borderWidth: 1 }] },
    options: { plugins: { legend: { labels: { color: '#e6ecff' } } }, scales: { x:{ticks:{color:'#e6ecff'}}, y:{ticks:{color:'#e6ecff'}} } }
  });
}

(function particles(){
  const c = document.getElementById('particles'); const ctx = c.getContext('2d');
  let w,h,pts=[]; const n=55;
  function resize(){w=c.width=innerWidth;h=c.height=innerHeight;}resize();addEventListener('resize',resize);
  pts=[...Array(n)].map(()=>({x:Math.random()*w,y:Math.random()*h,vx:(Math.random()-.5)*.5,vy:(Math.random()-.5)*.5}));
  function draw(){ctx.clearRect(0,0,w,h);pts.forEach(p=>{p.x+=p.vx;p.y+=p.vy;if(p.x<0||p.x>w)p.vx*=-1;if(p.y<0||p.y>h)p.vy*=-1;ctx.fillStyle='rgba(0,245,255,.7)';ctx.fillRect(p.x,p.y,2,2);});requestAnimationFrame(draw);}draw();
})();

renderQuestion();
