import React, { useState } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { Container } from '@mui/material'
import LoginPage from './LoginPage'
import Cafeteria from './Cafeteria'
import ScanQR from './ScanQRPage'
import ScanConfirm from './ScanConfirmPage'
import '../styles/app.css'

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  const handleLogin = () => setIsAuthenticated(true)
  const handleLogout = () => setIsAuthenticated(false)

  return (
    <BrowserRouter>
      <Container sx={{ mt: 0 }} className="app-container-inner">
        <Routes>
          <Route path="/login" element={<LoginPage onLogin={handleLogin} />} />
          <Route path="/cafeteria" element={<Cafeteria onLogout={handleLogout} />} />
          <Route path="/" element={<Navigate to={isAuthenticated ? '/cafeteria' : '/login'} replace />} />
          <Route path="*" element={<Navigate to="/" replace />} />
          <Route path="/scan-qr" element={<ScanQR />} />
          <Route path="/scan-confirm" element={<ScanConfirm />} />
        </Routes>
      </Container>
    </BrowserRouter>
  )
}
