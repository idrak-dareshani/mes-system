import React, { useState, useEffect } from 'react';
import {
  Container, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, MenuItem, IconButton, Chip, AppBar, Toolbar
} from '@mui/material';
import { Edit, Delete, Add } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const WorkStations = () => {
  const navigate = useNavigate();
  const [stations, setStations] = useState([]);
  const [open, setOpen] = useState(false);
  const [editStation, setEditStation] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    location: '',
    status: 'idle'
  });

  useEffect(() => {
    fetchStations();
  }, []);

  const fetchStations = async () => {
    try {
      const response = await axios.get('/api/workstations/');
      setStations(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error('Error fetching stations:', error);
      setStations([]);
    }
  };

  const handleSubmit = async () => {
    try {
      if (editStation) {
        await axios.put(`/api/workstations/${editStation.id}`, formData);
      } else {
        await axios.post('/api/workstations/', formData);
      }
      fetchStations();
      handleClose();
    } catch (error) {
      console.error('Error saving station:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/api/workstations/${id}`);
      fetchStations();
    } catch (error) {
      console.error('Error deleting station:', error);
    }
  };

  const handleEdit = (station) => {
    setEditStation(station);
    setFormData({
      name: station.name,
      location: station.location,
      status: station.status
    });
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditStation(null);
    setFormData({ name: '', location: '', status: 'idle' });
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'success';
      case 'maintenance': return 'warning';
      case 'error': return 'error';
      default: return 'default';
    }
  };

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
      
      <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>
        Work Stations
        <Button startIcon={<Add />} variant="contained" sx={{ ml: 2 }} onClick={() => setOpen(true)}>
          Add Station
        </Button>
      </Typography>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Location</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Current Order</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {(stations || []).map((station) => (
              <TableRow key={station.id}>
                <TableCell>{station.name}</TableCell>
                <TableCell>{station.location}</TableCell>
                <TableCell>
                  <Chip label={station.status} color={getStatusColor(station.status)} size="small" />
                </TableCell>
                <TableCell>{station.current_order_id || 'None'}</TableCell>
                <TableCell>
                  <IconButton onClick={() => handleEdit(station)}>
                    <Edit />
                  </IconButton>
                  <IconButton onClick={() => handleDelete(station.id)}>
                    <Delete />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
        <DialogTitle>{editStation ? 'Edit Station' : 'Add Station'}</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            margin="normal"
            label="Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Location"
            value={formData.location}
            onChange={(e) => setFormData({ ...formData, location: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Status"
            select
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value })}
          >
            <MenuItem value="idle">Idle</MenuItem>
            <MenuItem value="active">Active</MenuItem>
            <MenuItem value="maintenance">Maintenance</MenuItem>
            <MenuItem value="error">Error</MenuItem>
          </TextField>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained">Save</Button>
        </DialogActions>
        </Dialog>
      </Container>
    </>
  );
};

export default WorkStations;