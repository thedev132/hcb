import { Controller } from "@hotwired/stimulus"

/* eslint-disable */
// https://github.com/farzher/fuzzysort v2.0.4
const fuzzysort=(()=>{"use strict";var e=(e,r)=>{if("farzher"==e)return{target:"farzher was here (^-^*)/",score:0,_indexes:[0]};if(!e||!r)return j;var t=$(e);k(r)||(r=i(r));var a=t.bitflags;return(a&r._bitflags)!==a?j:l(t,r)},r=(e,r,t)=>{if("farzher"==e)return[{target:"farzher was here (^-^*)/",score:0,_indexes:[0],obj:r?r[0]:j}];if(!e)return t&&t.all?f(e,r,t):L;var a=$(e),n=a.bitflags,s=a.containsSpace,o=t&&t.threshold||C,v=t&&t.limit||y,g=0,c=0,d=r.length;if(t&&t.key)for(var u=t.key,_=0;_<d;++_){var h=r[_],p=w(h,u);if(p&&(k(p)||(p=i(p)),(n&p._bitflags)===n)){var x=l(a,p);x!==j&&!(x.score<o)&&(x={target:x.target,_targetLower:"",_targetLowerCodes:j,_nextBeginningIndexes:j,_bitflags:0,score:x.score,_indexes:x._indexes,obj:h},g<v?(z.add(x),++g):(++c,x.score>z.peek().score&&z.replaceTop(x)))}}else if(t&&t.keys)for(var S=t.scoreFn||b,B=t.keys,I=B.length,_=0;_<d;++_){for(var h=r[_],T=Array(I),m=0;m<I;++m){var u=B[m],p=w(h,u);if(!p){T[m]=j;continue}k(p)||(p=i(p)),(n&p._bitflags)!==n?T[m]=j:T[m]=l(a,p)}T.obj=h;var A=S(T);A!==j&&!(A<o)&&(T.score=A,g<v?(z.add(T),++g):(++c,A>z.peek().score&&z.replaceTop(T)))}else for(var _=0;_<d;++_){var p=r[_];if(p&&(k(p)||(p=i(p)),(n&p._bitflags)===n)){var x=l(a,p);x!==j&&!(x.score<o)&&(g<v?(z.add(x),++g):(++c,x.score>z.peek().score&&z.replaceTop(x)))}}if(0===g)return L;for(var F=Array(g),_=g-1;_>=0;--_)F[_]=z.poll();return F.total=g+c,F},t=(e,r,t)=>{if("function"==typeof r)return a(e,r);if(e===j)return j;void 0===r&&(r="<b>"),void 0===t&&(t="</b>");var n="",s=0,o=!1,i=e.target,$=i.length,f=e._indexes;f=f.slice(0,f.len).sort((e,r)=>e-r);for(var l=0;l<$;++l){var v=i[l];if(f[s]===l){if(++s,o||(o=!0,n+=r),s===f.length){n+=v+t+i.substr(l+1);break}}else o&&(o=!1,n+=t);n+=v}return n},a=(e,r)=>{if(e===j)return j;var t=e.target,a=t.length,n=e._indexes;n=n.slice(0,n.len).sort((e,r)=>e-r);for(var s="",o=0,i=0,$=!1,e=[],f=0;f<a;++f){var l=t[f];if(n[i]===f){if(++i,$||($=!0,e.push(s),s=""),i===n.length){s+=l,e.push(r(s,o++)),s="",e.push(t.substr(f+1));break}}else $&&($=!1,e.push(r(s,o++)),s="");s+=l}return e},n=e=>e._indexes.slice(0,e._indexes.len).sort((e,r)=>e-r),s=e=>{"string"!=typeof e&&(e="");var r=g(e);return{target:e,_targetLower:r._lower,_targetLowerCodes:r.lowerCodes,_nextBeginningIndexes:j,_bitflags:r.bitflags,score:j,_indexes:[0],obj:j}},o=e=>{"string"!=typeof e&&(e="");var r=g(e=e.trim()),t=[];if(r.containsSpace){var a=e.split(/\s+/);a=[...new Set(a)];for(var n=0;n<a.length;n++)if(""!==a[n]){var s=g(a[n]);t.push({lowerCodes:s.lowerCodes,_lower:a[n].toLowerCase(),containsSpace:!1})}}return{lowerCodes:r.lowerCodes,bitflags:r.bitflags,containsSpace:r.containsSpace,_lower:r._lower,spaceSearches:t}},i=e=>{if(e.length>999)return s(e);var r=_.get(e);return void 0!==r||(r=s(e),_.set(e,r)),r},$=e=>{if(e.length>999)return o(e);var r=h.get(e);return void 0!==r||(r=o(e),h.set(e,r)),r},f=(e,r,t)=>{var a=[];a.total=r.length;var n=t&&t.limit||y;if(t&&t.key)for(var s=0;s<r.length;s++){var o=r[s],$=w(o,t.key);if($){k($)||($=i($)),$.score=C,$._indexes.len=0;var f=$;if(f={target:f.target,_targetLower:"",_targetLowerCodes:j,_nextBeginningIndexes:j,_bitflags:0,score:$.score,_indexes:j,obj:o},a.push(f),a.length>=n)break}}else if(t&&t.keys)for(var s=0;s<r.length;s++){for(var o=r[s],l=Array(t.keys.length),v=t.keys.length-1;v>=0;--v){var $=w(o,t.keys[v]);if(!$){l[v]=j;continue}k($)||($=i($)),$.score=C,$._indexes.len=0,l[v]=$}if(l.obj=o,l.score=C,a.push(l),a.length>=n)break}else for(var s=0;s<r.length;s++){var $=r[s];if($&&(k($)||($=i($)),$.score=C,$._indexes.len=0,a.push($),a.length>=n))break}return a},l=(e,r,t=!1)=>{if(!1===t&&e.containsSpace)return v(e,r);for(var a,n,s=e._lower,o=e.lowerCodes,i=o[0],$=r._targetLowerCodes,f=o.length,l=$.length,g=0,c=0,u=0;;){var _=i===$[c];if(_){if(p[u++]=c,++g===f)break;i=o[g]}if(++c>=l)return j}var g=0,h=!1,b=0,w=r._nextBeginningIndexes;w===j&&(w=r._nextBeginningIndexes=d(r.target));var k=c=0===p[0]?0:w[p[0]-1],y=0;if(c!==l)for(;;)if(c>=l){if(g<=0||++y>200)break;--g,c=w[x[--b]]}else{var _=o[g]===$[c];if(_){if(x[b++]=c,++g===f){h=!0;break}++c}else c=w[c]}var C=r._targetLower.indexOf(s,p[0]),L=~C;if(L&&!h)for(var S=0;S<u;++S)p[S]=C+S;var z=!1;if(L&&(z=r._nextBeginningIndexes[C-1]===C),h)var B=x,I=b;else var B=p,I=u;for(var T=0,m=0,S=1;S<f;++S)B[S]-B[S-1]!=1&&(T-=B[S],++m);if(T-=(12+(B[f-1]-B[0]-(f-1)))*m,0!==B[0]&&(T-=B[0]*B[0]*.2),h){for(var A=1,S=w[0];S<l;S=w[S])++A;A>24&&(T*=(A-24)*10)}else T*=1e3;L&&(T/=1+f*f*1),z&&(T/=1+f*f*1),T-=l-f,r.score=T;for(var S=0;S<I;++S)r._indexes[S]=B[S];return r._indexes.len=I,r},v=(e,r)=>{for(var t,a=new Set,n=0,s=j,o=0,i=e.spaceSearches,$=0;$<i.length;++$){if((s=l(i[$],r))===j)return j;n+=s.score,s._indexes[0]<o&&(n-=o-s._indexes[0]),o=s._indexes[0];for(var f=0;f<s._indexes.len;++f)a.add(s._indexes[f])}var v=l(e,r,!0);if(v!==j&&v.score>n)return v;s.score=n;var $=0;for(let g of a)s._indexes[$++]=g;return s._indexes.len=$,s},g=e=>{for(var r=e.length,t=e.toLowerCase(),a=[],n=0,s=!1,o=0;o<r;++o){var i,$=a[o]=t.charCodeAt(o);if(32===$){s=!0;continue}n|=1<<($>=97&&$<=122?$-97:$>=48&&$<=57?26:$<=127?30:31)}return{lowerCodes:a,bitflags:n,containsSpace:s,_lower:t}},c=e=>{for(var r=e.length,t=[],a=0,n=!1,s=!1,o=0;o<r;++o){var i=e.charCodeAt(o),$=i>=65&&i<=90,f=$||i>=97&&i<=122||i>=48&&i<=57,l=$&&!n||!s||!f;n=$,s=f,l&&(t[a++]=o)}return t},d=e=>{for(var r=e.length,t=c(e),a=[],n=t[0],s=0,o=0;o<r;++o)n>o?a[o]=n:(n=t[++s],a[o]=void 0===n?r:n);return a},u=()=>{_.clear(),h.clear(),p=[],x=[]},_=new Map,h=new Map,p=[],x=[],b=e=>{for(var r=C,t=e.length,a=0;a<t;++a){var n=e[a];if(n!==j){var s=n.score;s>r&&(r=s)}}return r===C?j:r},w=(e,r)=>{var t=e[r];if(void 0!==t)return t;var a=r;Array.isArray(r)||(a=r.split("."));for(var n=a.length,s=-1;e&&++s<n;)e=e[a[s]];return e},k=e=>"object"==typeof e,y=1/0,C=-y,L=[];L.total=0;var S,j=null,z=(e=>{var r=[],t=0,a={},n=e=>{for(var a=0,n=r[a],s=1;s<t;){var o=s+1;a=s,o<t&&r[o].score<r[s].score&&(a=o),r[a-1>>1]=r[a],s=1+(a<<1)}for(var i=a-1>>1;a>0&&n.score<r[i].score;i=(a=i)-1>>1)r[a]=r[i];r[a]=n};return a.add=e=>{var a=t;r[t++]=e;for(var n=a-1>>1;a>0&&e.score<r[n].score;n=(a=n)-1>>1)r[a]=r[n];r[a]=e},a.poll=e=>{if(0!==t){var a=r[0];return r[0]=r[--t],n(),a}},a.peek=e=>{if(0!==t)return r[0]},a.replaceTop=e=>{r[0]=e,n()},a})();return{single:e,go:r,highlight:t,prepare:s,indexes:n,cleanup:u}})();
/* eslint-enable */

class Receipt {
  constructor(el) {
    this.filename = el.querySelector('strong').innerText.trim();
    this.id = el.getAttribute('data-receipt-id');
    this.content = el.getAttribute('data-textual-content');
  }

  get searchable() {
    return this.filename + " " + this.content;
  }
}

export default class extends Controller {
  static targets = [ "receipt", "select", "confirm", "noResults", "search" ]
  static values = { selected: String }

  select(e) {
    const prevReceiptId = this.selectElement.value + "";

    document.querySelectorAll(".receipt--selected").forEach(el => el.classList.remove("receipt--selected"));

    const receiptId = e.currentTarget.getAttribute("data-receipt-id");

    if (receiptId === prevReceiptId) {
      this.confirmTarget.disabled = true;
      this.selectElement.value = "";
      return this.#render();
    }

    this.confirmTarget.disabled = false;
    this.selectElement.value = receiptId;
    e.currentTarget.classList.add("receipt--selected");

    this.#render();
  }

  search() {
    this.#render();
  }

  #render() {
    const query = this.searchTarget.value;

    const receipts = this.#filter(query);


    const shown = this.receiptTargets.filter(el => receipts.find(r => r.obj.id === el.getAttribute("data-receipt-id")));
    if (query.length > 0) this.searchTarget.parentElement.setAttribute('data-results', `${shown.length} result${shown.length === 1 ? "" : "s"}`);
    else this.searchTarget.parentElement.removeAttribute('data-results');

    const hidden = this.receiptTargets.filter(el => !shown.includes(el));

    for (let i = 0; i < hidden.length; i++) {
      const el = hidden[i];
      if (el.classList.contains("receipt--selected")) {
        shown.push(hidden.splice(i, 1)[0]);
      }
    }

    shown.forEach(el => el.parentElement.style.display = "flex");


    for (let i = 0; i < shown.length; i++) {
      shown[i].parentElement.style.order = i;
    }

    hidden.forEach(el => el.parentElement.style.display = "none");

    if (shown.length === 0) {
      this.noResultsTarget.style.display = "block";
    }
    else {
      this.noResultsTarget.style.display = "none";
    }
  }

  #filter(query) {
    return fuzzysort.go(query, this.receipts, { keys: ["searchable"], all: true, threshold: -500000 });
  }

  get receipts() {
    return this.receiptTargets.map(el => new Receipt(el));
  }

  get selectElement() {
    return this.selectTarget.children[0];
  }
}
