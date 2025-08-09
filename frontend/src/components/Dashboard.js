import React, { useState, useEffect } from 'react';
import { Container, Grid, Paper, Typography, Card, CardContent, AppBar, Toolbar, Button } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const Dashboard = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    activeOrders: 0,
    completedToday: 0,
    qualityRate: 0,
    efficiency: 0
  });

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const response = await axios.get('/api/production-orders/');
      const orders = response.data;
      
      // Ensure orders is an array
      if (Array.isArray(orders)) {
        setStats({
          activeOrders: orders.filter(o => o.status === 'active').length,
          completedToday: orders.filter(o => o.status === 'completed').length,
          qualityRate: 98.5,
          efficiency: 87.2
        });
      } else {
        console.error('Expected array but got:', typeof orders, orders);
        setStats({
          activeOrders: 0,
          completedToday: 0,
          qualityRate: 98.5,
          efficiency: 87.2
        });
      }
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      setStats({
        activeOrders: 0,
        completedToday: 0,
        qualityRate: 98.5,
        efficiency: 87.2
      });
    }
  };

  const productionData = [
    { time: '08:00', production: 120 },
    { time: '10:00', production: 180 },
    { time: '12:00', production: 240 },
    { time: '14:00', production: 200 },
    { time: '16:00', production: 280 }
  ];

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            MES System
          </Typography>
          <Button color="inherit" onClick={() => navigate('/')}>Dashboard</Button>
          <Button color="inherit" onClick={() => navigate('/orders')}>Orders</Button>
          <Button color="inherit" onClick={() => navigate('/stations')}>Stations</Button>
          <Button color="inherit" onClick={() => navigate('/quality')}>Quality</Button>
        </Toolbar>
      </AppBar>
      
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Typography variant="h4" gutterBottom>
          MES Dashboard
        </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Active Orders
              </Typography>
              <Typography variant="h4">
                {stats.activeOrders}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Completed Today
              </Typography>
              <Typography variant="h4">
                {stats.completedToday}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Quality Rate
              </Typography>
              <Typography variant="h4">
                {stats.qualityRate}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Efficiency
              </Typography>
              <Typography variant="h4">
                {stats.efficiency}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom>
              Production Trend
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={productionData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="production" stroke="#1976d2" />
              </LineChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
        </Grid>
      </Container>
    </>
  );
};

export default Dashboard;