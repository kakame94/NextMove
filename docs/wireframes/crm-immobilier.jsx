import { useState, useMemo } from "react";
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from "recharts";
import { LayoutDashboard, Users, MessageSquare, Bell, Calendar, Settings, Search, Plus, Phone, Mail, MapPin, Home, ChevronRight, Clock, ArrowUpRight, ArrowDownRight, Filter, MoreVertical, Send, Paperclip, CheckCircle2, AlertCircle, X, ChevronDown, Edit3, Trash2, Eye, Star, DollarSign, TrendingUp, Building2 } from "lucide-react";

// ── Mock Data ──
const PROSPECTS = [
  { id: 1, nom: "Marie-Claire Dubois", email: "mc.dubois@gmail.com", tel: "514-555-0101", type: "Acheteur", budget: "650 000 $", secteur: "Plateau Mont-Royal", statut: "Chaud", propriete: "Condo 3½", dernierContact: "12 avr. 2026", score: 92, avatar: "MD" },
  { id: 2, nom: "Jean-François Tremblay", email: "jf.tremblay@outlook.com", tel: "438-555-0202", type: "Vendeur", budget: "850 000 $", secteur: "Villeray", statut: "Tiède", propriete: "Duplex", dernierContact: "10 avr. 2026", score: 74, avatar: "JT" },
  { id: 3, nom: "Sophie Lavoie", email: "s.lavoie@hotmail.com", tel: "514-555-0303", type: "Acheteur", budget: "420 000 $", secteur: "Rosemont", statut: "Chaud", propriete: "Condo 4½", dernierContact: "13 avr. 2026", score: 88, avatar: "SL" },
  { id: 4, nom: "Karim Benali", email: "k.benali@gmail.com", tel: "438-555-0404", type: "Acheteur", budget: "1 200 000 $", secteur: "Westmount", statut: "Nouveau", propriete: "Maison unifamiliale", dernierContact: "14 avr. 2026", score: 65, avatar: "KB" },
  { id: 5, nom: "Isabelle Gagnon", email: "i.gagnon@yahoo.ca", tel: "514-555-0505", type: "Vendeur", budget: "575 000 $", secteur: "Ahuntsic", statut: "Froid", propriete: "Triplex", dernierContact: "5 avr. 2026", score: 32, avatar: "IG" },
  { id: 6, nom: "Philippe Côté", email: "p.cote@gmail.com", tel: "438-555-0606", type: "Acheteur", budget: "380 000 $", secteur: "Verdun", statut: "Chaud", propriete: "Condo 3½", dernierContact: "11 avr. 2026", score: 85, avatar: "PC" },
  { id: 7, nom: "Nathalie Roy", email: "n.roy@outlook.com", tel: "514-555-0707", type: "Vendeur", budget: "720 000 $", secteur: "NDG", statut: "Tiède", propriete: "Condo 5½", dernierContact: "8 avr. 2026", score: 58, avatar: "NR" },
  { id: 8, nom: "Ahmed Khalil", email: "a.khalil@gmail.com", tel: "438-555-0808", type: "Acheteur", budget: "950 000 $", secteur: "Griffintown", statut: "Nouveau", propriete: "Penthouse", dernierContact: "14 avr. 2026", score: 70, avatar: "AK" },
];

const CONVERSATIONS = [
  { id: 1, prospect: "Marie-Claire Dubois", avatar: "MD", dernier: "Super, on peut visiter samedi 10h ?", heure: "13:42", unread: 2, messages: [
    { from: "prospect", text: "Bonjour, j'ai vu votre annonce pour le 4½ sur le Plateau.", time: "11:20" },
    { from: "agent", text: "Bonjour Marie-Claire ! Oui il est toujours disponible. Souhaitez-vous planifier une visite ?", time: "11:35" },
    { from: "prospect", text: "Super, on peut visiter samedi 10h ?", time: "13:42" },
  ]},
  { id: 2, prospect: "Jean-François Tremblay", avatar: "JT", dernier: "J'ai reçu l'évaluation, on en discute ?", heure: "10:15", unread: 1, messages: [
    { from: "agent", text: "Bonjour Jean-François, l'évaluateur est passé ce matin.", time: "09:00" },
    { from: "prospect", text: "J'ai reçu l'évaluation, on en discute ?", time: "10:15" },
  ]},
  { id: 3, prospect: "Karim Benali", avatar: "KB", dernier: "Merci pour les comparables !", heure: "Hier", unread: 0, messages: [
    { from: "agent", text: "Voici les comparables vendus à Westmount ce trimestre.", time: "16:00" },
    { from: "prospect", text: "Merci pour les comparables !", time: "16:30" },
  ]},
  { id: 4, prospect: "Philippe Côté", avatar: "PC", dernier: "Le financement est approuvé !", heure: "Hier", unread: 0, messages: [
    { from: "prospect", text: "Le financement est approuvé !", time: "14:00" },
  ]},
  { id: 5, prospect: "Sophie Lavoie", avatar: "SL", dernier: "Est-ce qu'on peut négocier le prix ?", heure: "11 avr.", unread: 0, messages: [
    { from: "prospect", text: "Est-ce qu'on peut négocier le prix ?", time: "09:30" },
  ]},
];

const RELANCES = [
  { id: 1, prospect: "Marie-Claire Dubois", avatar: "MD", type: "Visite", date: "15 avr. 2026", heure: "10:00", priorite: "haute", note: "Confirmer visite du 4½ Plateau — 4230 rue Drolet", statut: "à faire" },
  { id: 2, prospect: "Jean-François Tremblay", avatar: "JT", type: "Appel", date: "15 avr. 2026", heure: "14:00", priorite: "haute", note: "Discuter de l'évaluation du duplex Villeray", statut: "à faire" },
  { id: 3, prospect: "Isabelle Gagnon", avatar: "IG", type: "Courriel", date: "16 avr. 2026", heure: "09:00", priorite: "basse", note: "Relance mensuelle — triplex Ahuntsic toujours à vendre ?", statut: "à faire" },
  { id: 4, prospect: "Sophie Lavoie", avatar: "SL", type: "Appel", date: "16 avr. 2026", heure: "11:00", priorite: "moyenne", note: "Réponse négociation prix — contre-offre à préparer", statut: "à faire" },
  { id: 5, prospect: "Karim Benali", avatar: "KB", type: "Visite", date: "17 avr. 2026", heure: "15:00", priorite: "moyenne", note: "2e visite 45 Av. Forden, Westmount", statut: "planifié" },
  { id: 6, prospect: "Philippe Côté", avatar: "PC", type: "Document", date: "14 avr. 2026", heure: "—", priorite: "haute", note: "Envoyer promesse d'achat — financement approuvé", statut: "en retard" },
  { id: 7, prospect: "Nathalie Roy", avatar: "NR", type: "Courriel", date: "18 avr. 2026", heure: "10:00", priorite: "basse", note: "Suivi photos professionnelles condo NDG", statut: "planifié" },
];

const RDV = [
  { id: 1, titre: "Visite — 4230 Drolet", prospect: "Marie-Claire Dubois", avatar: "MD", date: "15 avr.", heure: "10:00 – 10:45", lieu: "4230 rue Drolet, Plateau", type: "Visite", color: "#3b5bdb" },
  { id: 2, titre: "Appel évaluation duplex", prospect: "Jean-François Tremblay", avatar: "JT", date: "15 avr.", heure: "14:00 – 14:30", lieu: "Téléphone", type: "Appel", color: "#40c057" },
  { id: 3, titre: "Signature promesse d'achat", prospect: "Philippe Côté", avatar: "PC", date: "16 avr.", heure: "09:30 – 10:30", lieu: "Bureau — 1500 rue Peel", type: "Signature", color: "#be4bdb" },
  { id: 4, titre: "Négociation prix", prospect: "Sophie Lavoie", avatar: "SL", date: "16 avr.", heure: "11:00 – 11:30", lieu: "Téléphone", type: "Appel", color: "#40c057" },
  { id: 5, titre: "2e visite — 45 Av. Forden", prospect: "Karim Benali", avatar: "KB", date: "17 avr.", heure: "15:00 – 16:00", lieu: "45 Av. Forden, Westmount", type: "Visite", color: "#3b5bdb" },
  { id: 6, titre: "Photos pro condo NDG", prospect: "Nathalie Roy", avatar: "NR", date: "18 avr.", heure: "13:00 – 14:00", lieu: "5678 Av. Monkland", type: "Service", color: "#fab005" },
];

const DASH_MONTHLY = [
  { mois: "Nov", prospects: 12, ventes: 2 }, { mois: "Déc", prospects: 8, ventes: 1 },
  { mois: "Jan", prospects: 15, ventes: 3 }, { mois: "Fév", prospects: 18, ventes: 2 },
  { mois: "Mar", prospects: 22, ventes: 4 }, { mois: "Avr", prospects: 14, ventes: 2 },
];
const DASH_PIE = [
  { name: "Chaud", value: 3, color: "#f03e3e" }, { name: "Tiède", value: 2, color: "#fab005" },
  { name: "Nouveau", value: 2, color: "#3b5bdb" }, { name: "Froid", value: 1, color: "#868e96" },
];

// ── Helpers ──
const cn = (...cls) => cls.filter(Boolean).join(" ");
const Badge = ({ children, variant = "default" }) => {
  const colors = { haute: "bg-red-500/15 text-red-400", moyenne: "bg-yellow-500/15 text-yellow-400", basse: "bg-slate-500/15 text-slate-400", "Chaud": "bg-red-500/15 text-red-400", "Tiède": "bg-yellow-500/15 text-yellow-400", "Nouveau": "bg-blue-500/15 text-blue-400", "Froid": "bg-slate-500/15 text-slate-400", "à faire": "bg-blue-500/15 text-blue-400", "planifié": "bg-green-500/15 text-green-400", "en retard": "bg-red-500/15 text-red-400", "Acheteur": "bg-emerald-500/15 text-emerald-400", "Vendeur": "bg-violet-500/15 text-violet-400", default: "bg-slate-500/15 text-slate-400" };
  return <span className={cn("text-xs font-semibold px-2.5 py-0.5 rounded-full", colors[children] || colors[variant] || colors.default)}>{children}</span>;
};
const Avatar = ({ initials, size = "md", color }) => {
  const s = size === "sm" ? "w-8 h-8 text-xs" : size === "lg" ? "w-12 h-12 text-base" : "w-10 h-10 text-sm";
  const bg = color || "bg-slate-700";
  return <div className={cn(s, bg, "rounded-full flex items-center justify-center font-bold text-white shrink-0")}>{initials}</div>;
};
const StatCard = ({ icon: Icon, label, value, delta, up }) => (
  <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5 flex flex-col gap-1">
    <div className="flex items-center justify-between">
      <div className="w-9 h-9 rounded-lg bg-slate-700/50 flex items-center justify-center"><Icon size={18} className="text-slate-400" /></div>
      {delta && <span className={cn("text-xs font-semibold flex items-center gap-0.5", up ? "text-green-400" : "text-red-400")}>{up ? <ArrowUpRight size={14}/> : <ArrowDownRight size={14}/>}{delta}</span>}
    </div>
    <div className="text-2xl font-bold text-white mt-2">{value}</div>
    <div className="text-xs text-slate-400">{label}</div>
  </div>
);

// ══════════ PAGES ══════════

// ── Dashboard ──
const PageDashboard = () => (
  <div className="space-y-6">
    <div className="grid grid-cols-4 gap-4">
      <StatCard icon={Users} label="Prospects actifs" value="8" delta="+12%" up />
      <StatCard icon={DollarSign} label="Volume pipeline" value="5,75 M$" delta="+8%" up />
      <StatCard icon={TrendingUp} label="Ventes ce mois" value="2" delta="-33%" up={false} />
      <StatCard icon={Calendar} label="RDV cette semaine" value="6" delta="+50%" up />
    </div>
    <div className="grid grid-cols-3 gap-4">
      <div className="col-span-2 bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
        <h3 className="text-sm font-semibold text-white mb-4">Prospects & ventes — 6 derniers mois</h3>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={DASH_MONTHLY}><XAxis dataKey="mois" tick={{fill:'#94a3b8',fontSize:12}} axisLine={false} tickLine={false}/><YAxis tick={{fill:'#94a3b8',fontSize:12}} axisLine={false} tickLine={false}/><Tooltip contentStyle={{background:'#1e293b',border:'1px solid #334155',borderRadius:8,fontSize:12}} /><Bar dataKey="prospects" fill="#3b5bdb" radius={[4,4,0,0]} /><Bar dataKey="ventes" fill="#40c057" radius={[4,4,0,0]} /></BarChart>
        </ResponsiveContainer>
      </div>
      <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
        <h3 className="text-sm font-semibold text-white mb-4">Pipeline par statut</h3>
        <ResponsiveContainer width="100%" height={180}>
          <PieChart><Pie data={DASH_PIE} cx="50%" cy="50%" innerRadius={50} outerRadius={75} paddingAngle={3} dataKey="value">{DASH_PIE.map((d,i)=><Cell key={i} fill={d.color}/>)}</Pie></PieChart>
        </ResponsiveContainer>
        <div className="flex flex-wrap gap-3 mt-2 justify-center">{DASH_PIE.map(d=><span key={d.name} className="text-xs text-slate-400 flex items-center gap-1.5"><span className="w-2.5 h-2.5 rounded-full" style={{background:d.color}}/>{d.name} ({d.value})</span>)}</div>
      </div>
    </div>
    <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
      <h3 className="text-sm font-semibold text-white mb-3">Prochaines relances</h3>
      <div className="space-y-2">{RELANCES.slice(0,4).map(r=>(
        <div key={r.id} className="flex items-center gap-3 p-2.5 rounded-lg hover:bg-slate-700/30 transition-colors">
          <Avatar initials={r.avatar} size="sm"/><div className="flex-1 min-w-0"><div className="text-sm font-medium text-white truncate">{r.prospect}</div><div className="text-xs text-slate-400 truncate">{r.note}</div></div><div className="text-xs text-slate-500">{r.date}</div><Badge>{r.priorite}</Badge>
        </div>
      ))}</div>
    </div>
  </div>
);

// ── Prospects ──
const PageProspects = () => {
  const [search, setSearch] = useState("");
  const [filtre, setFiltre] = useState("Tous");
  const filtered = PROSPECTS.filter(p => (filtre === "Tous" || p.statut === filtre || p.type === filtre) && (p.nom.toLowerCase().includes(search.toLowerCase()) || p.secteur.toLowerCase().includes(search.toLowerCase())));
  const [selected, setSelected] = useState(null);
  return (
    <div className="flex gap-5 h-full">
      <div className={cn("flex-1 space-y-4 transition-all", selected ? "max-w-[55%]" : "")}>
        <div className="flex gap-3">
          <div className="flex-1 relative"><Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"/><input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Rechercher un prospect..." className="w-full pl-10 pr-4 py-2.5 bg-slate-800/60 border border-slate-700/50 rounded-lg text-sm text-white placeholder-slate-500 outline-none focus:border-blue-500/50"/></div>
          <button className="px-4 py-2.5 bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium rounded-lg flex items-center gap-2 transition-colors"><Plus size={16}/>Ajouter</button>
        </div>
        <div className="flex gap-2">{["Tous","Chaud","Tiède","Nouveau","Froid","Acheteur","Vendeur"].map(f=><button key={f} onClick={()=>setFiltre(f)} className={cn("px-3 py-1.5 rounded-lg text-xs font-medium transition-colors", filtre===f?"bg-blue-600/20 text-blue-400 border border-blue-500/30":"bg-slate-800/40 text-slate-400 border border-slate-700/30 hover:border-slate-600/50")}>{f}</button>)}</div>
        <div className="space-y-2">{filtered.map(p=>(
          <div key={p.id} onClick={()=>setSelected(p)} className={cn("flex items-center gap-4 p-4 rounded-xl border transition-all cursor-pointer", selected?.id===p.id?"bg-slate-700/40 border-blue-500/40":"bg-slate-800/40 border-slate-700/30 hover:border-slate-600/50")}>
            <Avatar initials={p.avatar}/><div className="flex-1 min-w-0"><div className="flex items-center gap-2"><span className="text-sm font-semibold text-white">{p.nom}</span><Badge>{p.type}</Badge></div><div className="text-xs text-slate-400 mt-0.5 flex items-center gap-3"><span className="flex items-center gap-1"><MapPin size={11}/>{p.secteur}</span><span className="flex items-center gap-1"><Home size={11}/>{p.propriete}</span></div></div>
            <div className="text-right shrink-0"><Badge>{p.statut}</Badge><div className="text-xs text-slate-500 mt-1.5">{p.dernierContact}</div></div>
            <div className="w-10 h-10 rounded-full border-2 border-slate-700 flex items-center justify-center"><span className={cn("text-xs font-bold", p.score>=80?"text-green-400":p.score>=60?"text-yellow-400":"text-slate-400")}>{p.score}</span></div>
          </div>
        ))}</div>
      </div>
      {selected && (
        <div className="w-[360px] bg-slate-800/60 border border-slate-700/50 rounded-xl p-5 space-y-5 shrink-0">
          <div className="flex items-start justify-between"><div className="flex items-center gap-3"><Avatar initials={selected.avatar} size="lg"/><div><div className="text-base font-bold text-white">{selected.nom}</div><Badge>{selected.type}</Badge></div></div><button onClick={()=>setSelected(null)} className="text-slate-500 hover:text-white transition-colors"><X size={18}/></button></div>
          <div className="space-y-3 text-sm">{[{icon:Mail,val:selected.email},{icon:Phone,val:selected.tel},{icon:MapPin,val:selected.secteur},{icon:Home,val:selected.propriete},{icon:DollarSign,val:selected.budget}].map((r,i)=><div key={i} className="flex items-center gap-3 text-slate-300"><r.icon size={15} className="text-slate-500 shrink-0"/>{r.val}</div>)}</div>
          <div className="pt-3 border-t border-slate-700/50 space-y-2"><h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Actions rapides</h4><div className="grid grid-cols-2 gap-2">{[{icon:Phone,label:"Appeler"},{icon:Mail,label:"Courriel"},{icon:Calendar,label:"RDV"},{icon:Bell,label:"Relance"}].map(a=><button key={a.label} className="flex items-center gap-2 px-3 py-2 bg-slate-700/40 hover:bg-slate-700/70 rounded-lg text-xs text-slate-300 transition-colors"><a.icon size={14}/>{a.label}</button>)}</div></div>
        </div>
      )}
    </div>
  );
};

// ── Conversations ──
const PageConversations = () => {
  const [activeConv, setActiveConv] = useState(CONVERSATIONS[0]);
  const [newMsg, setNewMsg] = useState("");
  return (
    <div className="flex gap-0 h-[calc(100vh-140px)] rounded-xl overflow-hidden border border-slate-700/50">
      {/* Liste */}
      <div className="w-80 bg-slate-800/60 border-r border-slate-700/50 flex flex-col shrink-0">
        <div className="p-3"><div className="relative"><Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500"/><input placeholder="Rechercher..." className="w-full pl-9 pr-3 py-2 bg-slate-700/40 border border-slate-600/30 rounded-lg text-xs text-white placeholder-slate-500 outline-none"/></div></div>
        <div className="flex-1 overflow-y-auto">{CONVERSATIONS.map(c=>(
          <div key={c.id} onClick={()=>setActiveConv(c)} className={cn("flex items-center gap-3 px-4 py-3 cursor-pointer transition-colors border-l-2", activeConv.id===c.id?"bg-slate-700/40 border-blue-500":"border-transparent hover:bg-slate-700/20")}>
            <div className="relative"><Avatar initials={c.avatar} size="sm"/>{c.unread>0&&<span className="absolute -top-1 -right-1 w-4 h-4 bg-blue-500 rounded-full text-[10px] font-bold text-white flex items-center justify-center">{c.unread}</span>}</div>
            <div className="flex-1 min-w-0"><div className="flex justify-between"><span className={cn("text-sm truncate", c.unread?"font-semibold text-white":"text-slate-300")}>{c.prospect}</span><span className="text-[10px] text-slate-500 shrink-0">{c.heure}</span></div><div className={cn("text-xs truncate mt-0.5", c.unread?"text-slate-300":"text-slate-500")}>{c.dernier}</div></div>
          </div>
        ))}</div>
      </div>
      {/* Chat */}
      <div className="flex-1 flex flex-col bg-slate-900/40">
        <div className="px-5 py-3 border-b border-slate-700/50 flex items-center justify-between bg-slate-800/40"><div className="flex items-center gap-3"><Avatar initials={activeConv.avatar} size="sm"/><div><div className="text-sm font-semibold text-white">{activeConv.prospect}</div><div className="text-[10px] text-green-400">En ligne</div></div></div><div className="flex gap-2">{[Phone,Calendar,MoreVertical].map((Ic,i)=><button key={i} className="w-8 h-8 rounded-lg bg-slate-700/40 hover:bg-slate-700/70 flex items-center justify-center text-slate-400 transition-colors"><Ic size={16}/></button>)}</div></div>
        <div className="flex-1 overflow-y-auto p-5 space-y-3">{activeConv.messages.map((m,i)=>(
          <div key={i} className={cn("flex", m.from==="agent"?"justify-end":"justify-start")}>
            <div className={cn("max-w-[70%] px-4 py-2.5 rounded-2xl text-sm", m.from==="agent"?"bg-blue-600 text-white rounded-br-md":"bg-slate-700/60 text-slate-200 rounded-bl-md")}>
              {m.text}<div className={cn("text-[10px] mt-1", m.from==="agent"?"text-blue-200/60":"text-slate-500")}>{m.time}</div>
            </div>
          </div>
        ))}</div>
        <div className="p-4 border-t border-slate-700/50 bg-slate-800/30">
          <div className="flex items-center gap-2"><button className="w-9 h-9 rounded-lg bg-slate-700/40 hover:bg-slate-700/70 flex items-center justify-center text-slate-400 transition-colors shrink-0"><Paperclip size={16}/></button><input value={newMsg} onChange={e=>setNewMsg(e.target.value)} placeholder="Écrire un message..." className="flex-1 px-4 py-2.5 bg-slate-700/40 border border-slate-600/30 rounded-lg text-sm text-white placeholder-slate-500 outline-none focus:border-blue-500/50"/><button className="w-9 h-9 rounded-lg bg-blue-600 hover:bg-blue-500 flex items-center justify-center text-white transition-colors shrink-0"><Send size={16}/></button></div>
        </div>
      </div>
    </div>
  );
};

// ── Relances ──
const PageRelances = () => {
  const [tab, setTab] = useState("toutes");
  const filtered = tab === "toutes" ? RELANCES : RELANCES.filter(r => r.statut === tab);
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex gap-2">{[{k:"toutes",l:"Toutes"},{k:"en retard",l:"En retard"},{k:"à faire",l:"À faire"},{k:"planifié",l:"Planifié"}].map(t=><button key={t.k} onClick={()=>setTab(t.k)} className={cn("px-3.5 py-1.5 rounded-lg text-xs font-medium transition-colors", tab===t.k?"bg-blue-600/20 text-blue-400 border border-blue-500/30":"bg-slate-800/40 text-slate-400 border border-slate-700/30 hover:border-slate-600/50")}>{t.l} {t.k!=="toutes"&&<span className="ml-1 text-[10px] opacity-60">({RELANCES.filter(r=>t.k==="toutes"||r.statut===t.k).length})</span>}</button>)}</div>
        <button className="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium rounded-lg flex items-center gap-2 transition-colors"><Plus size={15}/>Nouvelle relance</button>
      </div>
      <div className="space-y-2">{filtered.map(r=>(
        <div key={r.id} className={cn("flex items-center gap-4 p-4 rounded-xl border transition-colors", r.statut==="en retard"?"bg-red-500/5 border-red-500/20":"bg-slate-800/40 border-slate-700/30 hover:border-slate-600/50")}>
          <Avatar initials={r.avatar}/>
          <div className="flex-1 min-w-0"><div className="flex items-center gap-2"><span className="text-sm font-semibold text-white">{r.prospect}</span><Badge>{r.type}</Badge><Badge>{r.statut}</Badge></div><div className="text-xs text-slate-400 mt-1">{r.note}</div></div>
          <div className="text-right shrink-0"><div className="text-sm font-medium text-white">{r.date}</div><div className="text-xs text-slate-500">{r.heure}</div></div>
          <Badge>{r.priorite}</Badge>
          <div className="flex gap-1">{[CheckCircle2, Edit3, Trash2].map((Ic,i)=><button key={i} className="w-7 h-7 rounded-md hover:bg-slate-700/50 flex items-center justify-center text-slate-500 hover:text-slate-300 transition-colors"><Ic size={14}/></button>)}</div>
        </div>
      ))}</div>
    </div>
  );
};

// ── Rendez-vous ──
const PageRendezvous = () => {
  const jours = ["Mar. 15 avr.", "Mer. 16 avr.", "Jeu. 17 avr.", "Ven. 18 avr."];
  const byJour = { "15 avr.": RDV.filter(r=>r.date==="15 avr."), "16 avr.": RDV.filter(r=>r.date==="16 avr."), "17 avr.": RDV.filter(r=>r.date==="17 avr."), "18 avr.": RDV.filter(r=>r.date==="18 avr.") };
  const keys = ["15 avr.","16 avr.","17 avr.","18 avr."];
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-bold text-white">Semaine du 14 avril 2026</h3>
        <button className="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium rounded-lg flex items-center gap-2 transition-colors"><Plus size={15}/>Nouveau RDV</button>
      </div>
      <div className="grid grid-cols-4 gap-4">
        {jours.map((j,idx)=>(
          <div key={j} className="space-y-2">
            <div className={cn("text-center text-xs font-semibold py-2 rounded-lg", idx===0?"bg-blue-600/20 text-blue-400":"bg-slate-800/40 text-slate-400")}>{j}</div>
            {(byJour[keys[idx]]||[]).map(rdv=>(
              <div key={rdv.id} className="bg-slate-800/60 border border-slate-700/40 rounded-xl p-3.5 space-y-2 hover:border-slate-600/50 transition-colors">
                <div className="flex items-center gap-2"><div className="w-2 h-2 rounded-full shrink-0" style={{background:rdv.color}}/><span className="text-xs font-semibold text-white truncate">{rdv.titre}</span></div>
                <div className="text-[11px] text-slate-400 flex items-center gap-1.5"><Clock size={11}/>{rdv.heure}</div>
                <div className="text-[11px] text-slate-500 flex items-center gap-1.5"><MapPin size={11}/>{rdv.lieu}</div>
                <div className="flex items-center gap-2 pt-1 border-t border-slate-700/30"><Avatar initials={rdv.avatar} size="sm"/><span className="text-xs text-slate-300">{rdv.prospect}</span></div>
              </div>
            ))}
            {(byJour[keys[idx]]||[]).length===0&&<div className="text-center text-xs text-slate-600 py-8">Aucun RDV</div>}
          </div>
        ))}
      </div>
    </div>
  );
};

// ── Configuration ──
const PageConfiguration = () => {
  const [notifs, setNotifs] = useState({ relance: true, rdv: true, message: true, rapport: false });
  const sections = [
    { title: "Profil agent", fields: [{ label: "Nom complet", val: "Eliot ALANMANOU" }, { label: "Courriel", val: "alanmanou.consulting@gmail.com" }, { label: "Téléphone", val: "514-XXX-XXXX" }, { label: "Agence", val: "— à configurer —" }, { label: "Permis OACIQ", val: "— à configurer —" }] },
    { title: "Intégrations", items: [{ name: "Centris (MLS)", status: "Connecté", on: true }, { name: "Gmail", status: "Connecté", on: true }, { name: "Google Calendar", status: "Non connecté", on: false }, { name: "DocuSign", status: "Non connecté", on: false }] },
  ];
  return (
    <div className="max-w-2xl space-y-6">
      {/* Profil */}
      <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
        <h3 className="text-sm font-semibold text-white mb-4 flex items-center gap-2"><Users size={16}/>Profil agent</h3>
        <div className="space-y-3">{sections[0].fields.map(f=>(
          <div key={f.label} className="flex items-center justify-between"><span className="text-xs text-slate-400">{f.label}</span><span className="text-sm text-white">{f.val}</span></div>
        ))}</div>
        <button className="mt-4 px-4 py-2 bg-slate-700/50 hover:bg-slate-700/80 text-sm text-slate-300 rounded-lg transition-colors flex items-center gap-2"><Edit3 size={14}/>Modifier</button>
      </div>
      {/* Notifications */}
      <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
        <h3 className="text-sm font-semibold text-white mb-4 flex items-center gap-2"><Bell size={16}/>Notifications</h3>
        <div className="space-y-3">{Object.entries(notifs).map(([k,v])=>(
          <div key={k} className="flex items-center justify-between">
            <span className="text-sm text-slate-300 capitalize">{k === "relance" ? "Rappels de relance" : k === "rdv" ? "Rendez-vous à venir" : k === "message" ? "Nouveaux messages" : "Rapport hebdomadaire"}</span>
            <button onClick={()=>setNotifs(n=>({...n,[k]:!n[k]}))} className={cn("w-10 h-6 rounded-full transition-colors relative", v ? "bg-blue-600" : "bg-slate-600")}><div className={cn("w-4 h-4 bg-white rounded-full absolute top-1 transition-transform", v?"translate-x-5":"translate-x-1")}/></button>
          </div>
        ))}</div>
      </div>
      {/* Intégrations */}
      <div className="bg-slate-800/60 border border-slate-700/50 rounded-xl p-5">
        <h3 className="text-sm font-semibold text-white mb-4 flex items-center gap-2"><Building2 size={16}/>Intégrations</h3>
        <div className="space-y-3">{sections[1].items.map(it=>(
          <div key={it.name} className="flex items-center justify-between p-3 rounded-lg bg-slate-700/20">
            <div><div className="text-sm font-medium text-white">{it.name}</div><div className={cn("text-xs", it.on?"text-green-400":"text-slate-500")}>{it.status}</div></div>
            <button className={cn("px-3 py-1.5 rounded-lg text-xs font-medium transition-colors", it.on?"bg-slate-700/50 text-slate-300 hover:bg-slate-700/80":"bg-blue-600 text-white hover:bg-blue-500")}>{it.on?"Déconnecter":"Connecter"}</button>
          </div>
        ))}</div>
      </div>
    </div>
  );
};

// ══════════ APP SHELL ══════════
const NAV = [
  { key: "dashboard", label: "Tableau de bord", icon: LayoutDashboard },
  { key: "prospects", label: "Prospects", icon: Users },
  { key: "conversations", label: "Conversations", icon: MessageSquare },
  { key: "relances", label: "Relances", icon: Bell },
  { key: "rdv", label: "Rendez-vous", icon: Calendar },
  { key: "config", label: "Configuration", icon: Settings },
];
const PAGES = { dashboard: PageDashboard, prospects: PageProspects, conversations: PageConversations, relances: PageRelances, rdv: PageRendezvous, config: PageConfiguration };

export default function App() {
  const [page, setPage] = useState("dashboard");
  const Page = PAGES[page];
  const currentLabel = NAV.find(n => n.key === page)?.label;
  return (
    <div className="flex h-screen bg-slate-900 text-white overflow-hidden">
      {/* Sidebar */}
      <aside className="w-56 bg-slate-900 border-r border-slate-800 flex flex-col shrink-0">
        <div className="px-5 py-5"><span className="text-base font-bold tracking-tight bg-gradient-to-r from-blue-400 to-violet-400 bg-clip-text text-transparent">Immo CRM</span></div>
        <nav className="flex-1 px-3 space-y-0.5">{NAV.map(n=>(
          <button key={n.key} onClick={()=>setPage(n.key)} className={cn("w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors", page===n.key?"bg-blue-600/15 text-blue-400 font-semibold":"text-slate-400 hover:bg-slate-800/60 hover:text-slate-200")}>
            <n.icon size={18}/>{n.label}
            {n.key==="conversations"&&<span className="ml-auto w-5 h-5 bg-blue-500 rounded-full text-[10px] font-bold flex items-center justify-center text-white">3</span>}
          </button>
        ))}</nav>
        <div className="p-4 border-t border-slate-800"><div className="flex items-center gap-3"><Avatar initials="EA" color="bg-blue-600" size="sm"/><div><div className="text-xs font-semibold text-white">Eliot A.</div><div className="text-[10px] text-slate-500">Agent immobilier</div></div></div></div>
      </aside>
      {/* Main */}
      <main className="flex-1 flex flex-col overflow-hidden">
        <header className="px-6 py-4 border-b border-slate-800 flex items-center justify-between shrink-0">
          <h1 className="text-lg font-bold">{currentLabel}</h1>
          <div className="flex items-center gap-3"><div className="relative"><Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500"/><input placeholder="Recherche globale..." className="pl-9 pr-4 py-2 bg-slate-800/60 border border-slate-700/50 rounded-lg text-xs text-white placeholder-slate-500 outline-none w-56 focus:border-blue-500/50"/></div><button className="relative w-9 h-9 rounded-lg bg-slate-800/60 border border-slate-700/50 flex items-center justify-center text-slate-400 hover:text-white transition-colors"><Bell size={16}/><span className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full text-[10px] font-bold flex items-center justify-center">2</span></button></div>
        </header>
        <div className="flex-1 overflow-y-auto p-6"><Page/></div>
      </main>
    </div>
  );
}

