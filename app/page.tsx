export default function Home() {
  return (
    <main
      style={{
        minHeight: '100vh',
        padding: '80px 20px',
        textAlign: 'center',
        background: '#0A1931',
        color: 'white',
      }}
    >
      <div style={{ maxWidth: '900px', margin: '0 auto' }}>
        <h1 style={{ fontSize: '72px', fontWeight: 900, letterSpacing: '-2px' }}>
          TradeLoom
        </h1>
        <p style={{ color: '#C67A3E', fontSize: '28px', marginTop: '10px' }}>
          Weaving Trust Into Every Build
        </p>
        <p style={{ marginTop: '20px', opacity: 0.8 }}>
          Edmonton Heaven Edition - Database LIVE - RLS Enabled - 11 Tables
        </p>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '20px',
            marginTop: '50px',
          }}
        >
          <div
            style={{
              border: '1px solid #C67A3E',
              padding: '30px',
              borderRadius: '12px',
            }}
          >
            <h3>Escrow Protection</h3>
            <p style={{ fontSize: '13px', opacity: 0.7, marginTop: '10px' }}>
              Stripe Connect Separate Charges and Transfers
            </p>
          </div>
          <div
            style={{
              border: '1px solid #C67A3E',
              padding: '30px',
              borderRadius: '12px',
            }}
          >
            <h3>Trust Stack</h3>
            <p style={{ fontSize: '13px', opacity: 0.7, marginTop: '10px' }}>
              KYC/KYB - License - Insurance - Lien Waivers
            </p>
          </div>
          <div
            style={{
              border: '1px solid #C67A3E',
              padding: '30px',
              borderRadius: '12px',
            }}
          >
            <h3>8% - 4% - 1.5%</h3>
            <p style={{ fontSize: '13px', opacity: 0.7, marginTop: '10px' }}>
              De-escalating fees - Job1 8% - Job2 4% - Job3+ 1.5%
            </p>
          </div>
        </div>

        <div style={{ marginTop: '50px' }}>
          <p style={{ fontSize: '14px', opacity: 0.6 }}>
            Built by two brothers in Edmonton Heaven - Scalable OS - No Rebuild Needed
          </p>
          <p style={{ marginTop: '20px', fontSize: '12px', opacity: 0.5 }}>
            Database: tradeloom-heaven - 11 tables - PostGIS - Supabase - tradeloom.ca
          </p>
        </div>
      </div>
    </main>
  )
}
