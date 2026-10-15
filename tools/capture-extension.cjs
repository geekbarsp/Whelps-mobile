const fs=require('node:fs');
async function attach(target){
 const ws=new WebSocket(target.webSocketDebuggerUrl);await new Promise(r=>ws.addEventListener('open',r));let id=0;const waiting=new Map();ws.addEventListener('message',event=>{const m=JSON.parse(event.data);if(waiting.has(m.id)){waiting.get(m.id)(m);waiting.delete(m.id);}});
 return {send:async(method,params={})=>{const call=++id;const result=new Promise(r=>waiting.set(call,r));ws.send(JSON.stringify({id:call,method,params}));return result;},close:()=>ws.close()};
}
(async()=>{
 const targets=await(await fetch('http://127.0.0.1:9223/json/list')).json();
 const frame=await attach(targets.find(t=>t.url==='http://localhost:8080/'));
 await frame.send('Runtime.evaluate',{expression:"document.querySelector('flt-semantics-placeholder')?.click()"});
 await new Promise(r=>setTimeout(r,600));
 await frame.send('Runtime.evaluate',{expression:"[...document.querySelectorAll('[role=button]')].find(e=>e.textContent.includes('Browse pets as a guest'))?.click()"});
 await new Promise(r=>setTimeout(r,1000));
 const main=await attach(targets.find(t=>t.type==='page'));
 const result=await main.send('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});
 if(result.error)throw new Error(JSON.stringify(result.error));
 fs.writeFileSync('docs/validation/vscode-mobile-preview.png',Buffer.from(result.result.data,'base64'));
 frame.close();main.close();console.log('Captured actual Mobile Preview extension');
})();
