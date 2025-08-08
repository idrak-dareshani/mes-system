import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Dashboard from './components/Dashboard';
import ProductionOrders from './components/ProductionOrders';
import WorkStations from './components/WorkStations';
import QualityControl from './components/QualityControl';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/orders" element={<ProductionOrders />} />
          <Route path="/stations" element={<WorkStations />} />
          <Route path="/quality" element={<QualityControl />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;