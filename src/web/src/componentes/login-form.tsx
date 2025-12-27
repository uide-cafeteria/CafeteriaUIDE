import type React from "react"

import { useState } from "react"
import { Box, TextField, Button, Typography, Paper, InputAdornment, IconButton, Avatar, Container } from "@mui/material"
import '../styles/login-form.css'
import { Visibility, VisibilityOff, Coffee, Lock, Person } from "@mui/icons-material"

export function LoginForm({ onLogin }: { onLogin?: () => void }) {
  const [showPassword, setShowPassword] = useState(false)
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.log("Login attempt:", { email, password })
    // Aquí irá tu lógica de autenticación. Si la autenticación es correcta,
    // llamamos a `onLogin` para notificar al componente padre.
    if (onLogin) onLogin()
  }

  const handleClickShowPassword = () => {
    setShowPassword(!showPassword)
  }

  return (
    <Container maxWidth="sm" className="login-container">
      <Paper elevation={8} className="login-paper">
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 3,
          }}
        >
          {/* Logo / Icon */}
          <Avatar className="login-avatar">
            <Coffee sx={{ fontSize: 40, color: 'var(--card-foreground)' }} />
          </Avatar>

          {/* Title */}
          <Box className="login-title">
            <Typography
              variant="h4"
              component="h1"
              sx={{
                fontWeight: 700,
                color: "oklch(0.3 0.04 45)",
                mb: 1,
                fontSize: { xs: "1.75rem", sm: "2.125rem" },
              }}
            >
              Admin Portal
            </Typography>
            <Typography
              variant="body1"
              sx={{
                color: "oklch(0.55 0.03 45)",
                fontWeight: 500,
              }}
            >
              Bienvenido a tu cafetería
            </Typography>
          </Box>

          {/* Form */}
          <Box
            component="form"
            onSubmit={handleSubmit}
            sx={{
              width: "100%",
              display: "flex",
              flexDirection: "column",
              gap: 2.5,
              mt: 1,
            }}
          >
            <TextField
              fullWidth
              label="Correo electrónico"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Person sx={{ color: "oklch(0.45 0.08 50)" }} />
                  </InputAdornment>
                ),
              }}
              sx={{
                "& .MuiOutlinedInput-root": {
                  backgroundColor: "white",
                  borderRadius: 2,
                  "& fieldset": {
                    borderColor: "oklch(0.88 0.02 85)",
                    borderWidth: 2,
                  },
                  "&:hover fieldset": {
                    borderColor: "oklch(0.75 0.06 200)",
                  },
                  "&.Mui-focused fieldset": {
                    borderColor: "oklch(0.45 0.08 50)",
                  },
                },
                "& .MuiInputLabel-root": {
                  color: "oklch(0.55 0.03 45)",
                  "&.Mui-focused": {
                    color: "oklch(0.45 0.08 50)",
                  },
                },
              }}
            />

            <TextField
              fullWidth
              label="Contraseña"
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              autoComplete="current-password"
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Lock sx={{ color: "oklch(0.45 0.08 50)" }} />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={handleClickShowPassword}
                      edge="end"
                      sx={{ color: "oklch(0.55 0.03 45)" }}
                    >
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              sx={{
                "& .MuiOutlinedInput-root": {
                  backgroundColor: "white",
                  borderRadius: 2,
                  "& fieldset": {
                    borderColor: "oklch(0.88 0.02 85)",
                    borderWidth: 2,
                  },
                  "&:hover fieldset": {
                    borderColor: "oklch(0.75 0.06 200)",
                  },
                  "&.Mui-focused fieldset": {
                    borderColor: "oklch(0.45 0.08 50)",
                  },
                },
                "& .MuiInputLabel-root": {
                  color: "oklch(0.55 0.03 45)",
                  "&.Mui-focused": {
                    color: "oklch(0.45 0.08 50)",
                  },
                },
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              sx={{
                mt: 1,
                py: 1.5,
                fontSize: "1rem",
                fontWeight: 600,
                borderRadius: 2,
                textTransform: "none",
                backgroundColor: "oklch(0.45 0.08 50)",
                color: "oklch(0.98 0.01 85)",
                boxShadow: "0 4px 16px rgba(115, 80, 60, 0.25)",
                "&:hover": {
                  backgroundColor: "oklch(0.4 0.09 48)",
                  boxShadow: "0 6px 20px rgba(115, 80, 60, 0.35)",
                  transform: "translateY(-1px)",
                  transition: "all 0.2s ease-in-out",
                },
                "&:active": {
                  transform: "translateY(0)",
                },
              }}
            >
              Iniciar Sesión
            </Button>

            {/* Additional Actions */}
            <Box sx={{ textAlign: "center", mt: 1 }}>
              <Typography
                variant="body2"
                sx={{
                  color: "oklch(0.55 0.03 45)",
                  cursor: "pointer",
                  "&:hover": {
                    color: "oklch(0.45 0.08 50)",
                    textDecoration: "underline",
                  },
                }}
              >
                ¿Olvidaste tu contraseña?
              </Typography>
            </Box>
          </Box>

          {/* Footer */}
          <Box sx={{ textAlign: "center", mt: 2 }}>
            <Typography
              variant="caption"
              sx={{
                color: "oklch(0.65 0.02 45)",
                display: "flex",
                alignItems: "center",
                gap: 0.5,
                justifyContent: "center",
              }}
            >
              Powered by
              <Coffee sx={{ fontSize: 14 }} />
              Cafetería Admin
            </Typography>
          </Box>
        </Box>
      </Paper>
    </Container>
  )
}
