import React, { useState } from 'react'
import { Box, TextField, Button, Typography, Paper, InputAdornment, IconButton, Avatar, Container, Alert } from '@mui/material'
import { Visibility, VisibilityOff, Coffee, Lock, Person } from '@mui/icons-material'
import q_powered from '../media/Q_powered.png'
import '../styles/login-form.css'

export function LoginForm({ onLogin }) {
  const [showPassword, setShowPassword] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await fetch('http://localhost:3001/api/usuario/auth/admin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ correo: email, contrasenia: password })
      })

      let data = {}
      try { data = await res.json() } catch (_) { data = {} }

      if (!res.ok) {
        const msg = data.message || data.error || 'Credenciales inválidas'
        setError(msg)
        setLoading(false)
        return
      }

      // Si el backend devuelve un token lo guardamos
      const token = data.token || data.accessToken || data.access_token || null
      if (token) {
        try { localStorage.setItem('authToken', token) } catch (_) { }
      }

      if (onLogin) onLogin()
    } catch (err) {
      setError('Error de conexión con el servidor')
    } finally {
      setLoading(false)
    }
  }

  const handleClickShowPassword = () => {
    setShowPassword(!showPassword)
  }

  return (
    <Container maxWidth="sm" className="login-container">
      <Paper elevation={8} className="login-paper">
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 3,
          }}
        >
          <Avatar className="login-avatar">
            <Coffee sx={{ fontSize: 40, color: 'var(--card-foreground)' }} />
          </Avatar>

          <Box className="login-title">
            <Typography
              variant="h4"
              component="h1"
              sx={{
                fontWeight: 700,
                color: 'var(--foreground)',
                mb: 1,
                fontSize: { xs: '1.75rem', sm: '2.125rem' },
              }}
            >
              Admin Portal
            </Typography>
            <Typography
              variant="body1"
              sx={{
                color: 'var(--primary)',
                fontWeight: 500,
              }}
            >
              Bienvenido a tu cafetería
            </Typography>
          </Box>

          <Box
            component="form"
            onSubmit={handleSubmit}
            sx={{
              width: '100%',
              display: 'flex',
              flexDirection: 'column',
              gap: 2.5,
              mt: 1,
            }}
          >
            {error && (
              <Alert severity="error" onClose={() => setError('')}>
                {error}
              </Alert>
            )}
            <TextField
              fullWidth
              label="Correo electrónico"
              placeholder="email@email.com"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Person sx={{ color: 'var(--primary)' }} />
                  </InputAdornment>
                ),
              }}
              sx={{
                '& .MuiOutlinedInput-root': {
                  backgroundColor: 'white',
                  borderRadius: 2,
                },
              }}
            />

            <TextField
              fullWidth
              label="Contraseña"
              placeholder="Contraseña"
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Lock sx={{ color: 'var(--primary)' }} />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={handleClickShowPassword}
                      edge="end"
                      sx={{ color: 'var(--primary)' }}
                    >
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              sx={{
                '& .MuiOutlinedInput-root': {
                  backgroundColor: 'white',
                  borderRadius: 2,
                },
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{
                mt: 1,
                py: 1.5,
                fontSize: '1rem',
                fontWeight: 600,
                borderRadius: 2,
                textTransform: 'none',
                backgroundColor: 'var(--primary)',
                color: 'var(--background)',
              }}
            >
              {loading ? 'Iniciando...' : 'Iniciar Sesión'}
            </Button>

            <Box sx={{ textAlign: 'center', mt: 1 }}>
              <Typography
                variant="body2"
                sx={{
                  color: 'var(--foreground)',
                  cursor: 'pointer',
                }}
              >
                ¿Olvidaste tu contraseña?
              </Typography>
            </Box>
          </Box>

          <Box sx={{ textAlign: 'center', mt: 2 }}>
            <Typography
              variant="caption"
              sx={{
                color: 'var(--foreground)',
                display: 'flex',
                alignItems: 'center',
                gap: 1,
                justifyContent: 'center',
              }}
            >
              Powered by
              <Box
                component="span"
                sx={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 0.2,
                }}
              >
                <Box
                  component="img"
                  src={q_powered}
                  alt="YaQbit"
                  sx={{
                    height: 22,
                    transition: 'transform 0.2s',
                    '&:hover': {
                      transform: 'scale(1.1)',
                    },
                  }}
                />
                <Box component="span" sx={{ fontWeight: 'bold' }}>YaQbit</Box>
              </Box>
            </Typography>
          </Box>
        </Box>
      </Paper>
    </Container>
  )
}
