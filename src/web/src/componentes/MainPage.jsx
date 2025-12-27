import React from 'react'
import { Box, Typography, Button, Container, Paper } from '@mui/material'
import '../styles/mainpage.css'

export default function MainPage({ onLogout }) {
  return (
    <Container maxWidth="md" className="mainpage-root">
      <Paper elevation={6} className="mainpage-paper">
        <Box className="mainpage-header">
          <Box>
            <Typography variant="h4" component="h1" gutterBottom>
              Panel Principal
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Bienvenido al panel de administración de la cafetería.
            </Typography>
          </Box>
          <Button variant="outlined" color="primary" onClick={onLogout}>
            Cerrar sesión
          </Button>
        </Box>

        <Box className="mainpage-summary">
          <Typography variant="h6">Resumen</Typography>
          <Typography variant="body2" color="text.secondary">
            Aquí puedes mostrar estadísticas, accesos rápidos, y las operaciones principales.
          </Typography>
        </Box>
      </Paper>
    </Container>
  )
}
