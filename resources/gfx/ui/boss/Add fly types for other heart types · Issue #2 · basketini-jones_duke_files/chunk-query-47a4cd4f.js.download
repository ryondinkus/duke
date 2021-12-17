System.register(["./chunk-vendor.js"],function(m){"use strict";var b,f,g,h,c,y;return{setters:[function(a){b=a.b,f=a.c,g=a.$,h=a.a0,c=a.j,y=a.t}],execute:function(){var a=Object.defineProperty,$=Object.getOwnPropertyDescriptor,T=(e,t)=>a(e,"name",{value:t,configurable:!0}),v=(e,t,s,r)=>{for(var i=r>1?void 0:r?$(t,s):t,p=e.length-1,l;p>=0;p--)(l=e[p])&&(i=(r?l(t,s,i):l(i))||i);return r&&i&&a(t,s,i),i};let n=class extends HTMLElement{connectedCallback(){this.classList.add("Truncate","d-inline-flex")}get lastToken(){return this.tokens[this.tokens.length-1]}get text(){return this.tokens.map(e=>e.text).join("/")}get id(){return this.lastToken?this.lastToken.id:n.emptyScope.id}get type(){return this.lastToken?this.lastToken.type:n.emptyScope.type}get scope(){return this.hasScope()?{text:this.text,type:this.type,id:this.id,tokens:this.tokens}:n.emptyScope}set scope(e){this.renderTokens(e.tokens)}renderTokens(e){this.clearScope();const t=T(r=>h`${r.map(s)}`,"tokensTemplate"),s=T(r=>{const i=r.text.length>27?`${r.text.substring(0,24)}...`:r.text;return h`
        <command-palette-token
          data-text="${r.text}"
          data-id="${r.id}"
          data-type="${r.type}"
          data-value="${r.value}"
          data-targets="command-palette-scope.tokens"
          class="color-fg-default text-semibold"
          >${i}<span class="color-fg-subtle text-normal">&nbsp;&nbsp;/&nbsp;&nbsp;</span>
        </command-palette-token>
      `},"tokenTemplate");g(t(e),this),this.hidden=!this.hasScope()}removeToken(){this.lastToken&&(this.lastRemovedToken=this.lastToken,this.lastToken.remove(),this.renderTokens(this.tokens))}hasScope(){return this.tokens.length>0&&this.type&&this.id&&this.text}clearScope(){for(const e of this.tokens)e.remove()}};T(n,"CommandPaletteScopeElement"),n.emptyScope={type:"",text:"",id:"",tokens:[]},v([b],n.prototype,"tokens",2),n=v([f],n);var x=Object.defineProperty,j=Object.getOwnPropertyDescriptor,_=(e,t)=>x(e,"name",{value:t,configurable:!0}),u=(e,t,s,r)=>{for(var i=r>1?void 0:r?j(t,s):t,p=e.length-1,l;p>=0;p--)(l=e[p])&&(i=(r?l(t,s,i):l(i))||i);return r&&i&&x(t,s,i),i};let o=m("C",class extends HTMLElement{constructor(){super(...arguments);this.defaultPriority=0}connectedCallback(){this.classList.add("py-2","border-top"),this.setAttribute("hidden","true"),this.renderElement("")}prepareForNewItems(){this.list.innerHTML="",this.setAttribute("hidden","true"),this.classList.contains("border-top")||this.classList.add("border-top")}hasItem(e){return this.list.querySelectorAll(`[data-item-id="${e.id}"]`).length>0}renderElement(e){g(_(()=>this.hasTitle?h`
          <div class="d-flex flex-justify-between my-2 px-3">
            <span data-target="command-palette-item-group.header" class="color-fg-muted text-bold f6 text-normal">
              ${this.groupTitle}
            </span>
            <span data-target="command-palette-item-group.header" class="color-fg-muted f6 text-normal">
              ${e?"":this.groupHint}
            </span>
          </div>
          <div
            role="listbox"
            class="list-style-none"
            data-target="command-palette-item-group.list"
            aria-label="${this.groupTitle} results"
          ></div>
        `:h`
          <div
            role="listbox"
            class="list-style-none"
            data-target="command-palette-item-group.list"
            aria-label="${this.groupTitle} results"
          ></div>
        `,"groupTemplate")(),this)}push(e){this.removeAttribute("hidden"),this.topGroup&&this.atLimit?e.itemId!==this.firstItem.itemId&&this.replaceTopGroupItem(e):this.list.append(e)}replaceTopGroupItem(e){this.list.replaceChild(e,this.firstItem)}groupLimitForScope(){const e=this.closest("command-palette");if(e){const t=e.query.scope.type;return JSON.parse(this.groupLimits)[t]}}get limit(){const e=this.groupLimitForScope();return this.topGroup?1:this.isModeActive()?50:e||o.defaultGroupLimit}isModeActive(){const e=this.closest("command-palette");return e?e.getMode():!1}get atLimit(){return this.list.children.length>=this.limit}get topGroup(){return this.groupId===o.topGroupId}get hasTitle(){return this.groupId!==o.footerGroupId}get itemNodes(){return this.list.querySelectorAll("command-palette-item")}get firstItem(){return this.itemNodes[0]}get lastItem(){return this.itemNodes[this.itemNodes.length-1]}});_(o,"CommandPaletteItemGroupElement"),o.defaultGroupLimit=5,o.topGroupId="top",o.defaultGroupId="default",o.footerGroupId="footer",o.helpGroupIds=["modes_help","filters_help"],o.commandGroupIds=["commands"],o.topGroupScoreThreshold=9,u([c],o.prototype,"groupTitle",2),u([c],o.prototype,"groupHint",2),u([c],o.prototype,"groupId",2),u([c],o.prototype,"groupLimits",2),u([c],o.prototype,"defaultPriority",2),u([y],o.prototype,"list",2),u([y],o.prototype,"header",2),o=m("C",u([f],o));var S=Object.defineProperty,P=Object.getOwnPropertySymbols,k=Object.prototype.hasOwnProperty,G=Object.prototype.propertyIsEnumerable,I=(e,t,s)=>t in e?S(e,t,{enumerable:!0,configurable:!0,writable:!0,value:s}):e[t]=s,L=(e,t)=>{for(var s in t||(t={}))k.call(t,s)&&I(e,s,t[s]);if(P)for(var s of P(t))G.call(t,s)&&I(e,s,t[s]);return e},O=(e,t)=>S(e,"name",{value:t,configurable:!0});class d{constructor(t,s,{scope:r,subjectId:i,subjectType:p,returnTo:l}={}){this.queryText=t,this.queryMode=s,this.scope=r!=null?r:n.emptyScope,this.subjectId=i,this.subjectType=p,this.returnTo=l}get text(){return this.queryText}get mode(){return this.queryMode}get path(){return this.buildPath(this)}buildPath(t,s=t.text){return`scope:${t.scope.type}-${t.scope.id}/mode:${t.mode}/query:${s}`}clearScope(){this.scope=n.emptyScope}hasScope(){return this.scope.id!==n.emptyScope.id}isBlank(){return this.text.trim().length===0}isPresent(){return!this.isBlank()}immutableCopy(){const t=this.text,s=this.mode,r=L({},this.scope);return new d(t,s,{scope:r,subjectId:this.subjectId,subjectType:this.subjectType,returnTo:this.returnTo})}hasSameScope(t){return this.scope.id===t.scope.id}params(){const t=new URLSearchParams;return this.isPresent()&&t.set("q",this.text),this.hasScope()&&t.set("scope",this.scope.id),this.mode&&t.set("mode",this.mode),this.returnTo&&t.set("return_to",this.returnTo),this.subjectId&&t.set("subject",this.subjectId),t}}m("Q",d),O(d,"Query")}}});
//# sourceMappingURL=chunk-query-a215f94d.js.map
