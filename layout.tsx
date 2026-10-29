export const metadata = {
  title: 'TradeLoom - Weaving Trust Into Every Build',
  description: 'Edmonton Heaven Edition',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'Inter, sans-serif' }}>
        {children}
      </body>
    </html>
  )
}
