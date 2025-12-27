import React from 'react'
import { useNavigate } from 'react-router-dom'
import { LoginForm } from '../componentes/login-form'

export default function LoginPage({ onLogin }) {
  const navigate = useNavigate()

  const handleLogin = () => {
    if (onLogin) onLogin()
    navigate('/cafeteria')
  }

  return <LoginForm onLogin={handleLogin} />
}
