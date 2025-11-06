'use client';

import { useEffect, useState } from 'react';
import { db, storage, auth } from '@/lib/firebase';
import { addDoc, collection, onSnapshot, query, orderBy, serverTimestamp } from 'firebase/firestore';
import { getDownloadURL, ref, uploadBytes } from 'firebase/storage';

type Sound = {
  id: string;
  name: string;
  storagePath: string;
  createdAt?: any;
};

export default function SoundsPage() {
  const [file, setFile] = useState<File | null>(null);
  const [name, setName] = useState('');
  const [sounds, setSounds] = useState<Sound[]>([]);

  useEffect(() => {
    const q = query(collection(db, 'sounds'), orderBy('createdAt', 'desc'));
    const unsub = onSnapshot(q, (snap) => {
      setSounds(
        snap.docs.map((d) => ({
          id: d.id,
          name: d.data().name ?? d.id,
          storagePath: d.data().storagePath ?? '',
          createdAt: d.data().createdAt,
        }))
      );
    });
    return () => unsub();
  }, []);

  async function upload() {
    if (!file || !name) return;
    const ext = file.name.split('.').pop();
    const storagePath = `sounds/${Date.now()}-${name}.${ext}`;
    const storageRef = ref(storage, storagePath);
    await uploadBytes(storageRef, file);
    await addDoc(collection(db, 'sounds'), {
      name,
      storagePath,
      createdAt: serverTimestamp(),
      createdBy: auth.currentUser?.uid ?? null,
    });
    setFile(null);
    setName('');
  }

  return (
    <main style={{ maxWidth: 720, margin: '40px auto', padding: 16 }}>
      <h1>Sounds</h1>
      <section style={{ display: 'grid', gap: 8, marginBottom: 24 }}>
        <input placeholder="Sound name" value={name} onChange={(e) => setName(e.target.value)} />
        <input type="file" accept="audio/*" onChange={(e) => setFile(e.target.files?.[0] ?? null)} />
        <button onClick={upload} disabled={!file || !name}>
          Upload
        </button>
      </section>
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {sounds.map((s) => (
          <li key={s.id} style={{ padding: '8px 0', borderBottom: '1px solid #ddd' }}>
            <strong>{s.name}</strong>
            <div>{s.storagePath}</div>
            <SoundPlayer storagePath={s.storagePath} />
          </li>
        ))}
      </ul>
    </main>
  );
}

function SoundPlayer({ storagePath }: { storagePath: string }) {
  const [url, setUrl] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    (async () => {
      const u = await getDownloadURL(ref(storage, storagePath));
      if (mounted) setUrl(u);
    })();
    return () => {
      mounted = false;
    };
  }, [storagePath]);

  if (!url) return <span>Loading URL...</span>;

  return <audio controls src={url} style={{ width: '100%', marginTop: 8 }} />;
}