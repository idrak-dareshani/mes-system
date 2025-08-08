import React, { useState, useEffect } from 'react';
import {
  Container, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, IconButton, Chip, AppBar, Toolbar, MenuItem
} from '@mui/material';
import { Edit, Delete, Add } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const QualityControl = () => {
  const navigate = useNavigate();
  const [checks, setChecks] = useState([]);
  const [orders, setOrders] = useState([]);
  const [open, setOpen] = useState(false);
  const [editCheck, setEditCheck] = useState(null);
  const [formData, setFormData] = useState({
    order_id: '',
    parameter: '',
    value: '',
    specification_min: '',
    specification_max: '',
    passed: true
  });

  useEffect(() => {
    fetchChecks();
    fetchOrders();
  }, []);

  const fetchChecks = async () => {
    try {
      const response = await axios.get('/quality-checks/');
      setChecks(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error('Error fetching checks:', error);
      setChecks([]);
    }
  };

  const fetchOrders = async () => {
    try {
      const response = await axios.get('/production-orders/');
      const activeOrders = response.data.filter(order => order.status === 'active' || order.status === 'pending');
      setOrders(Array.isArray(activeOrders) ? activeOrders : []);
    } catch (error) {
      console.error('Error fetching orders:', error);
      setOrders([]);
    }
  };

  const handleSubmit = async () => {
    try {
      const value = parseFloat(formData.value);
      const min = parseFloat(formData.specification_min);
      const max = parseFloat(formData.specification_max);
      const passed = value >= min && value <= max;
      
      const data = {
        ...formData,
        order_id: parseInt(formData.order_id),
        value: value,
        specification_min: min,
        specification_max: max,
        passed: passed
      };
      
      if (editCheck) {
        await axios.put(`/quality-checks/${editCheck.id}`, data);
      } else {
        await axios.post('/quality-checks/', data);
      }
      fetchChecks();
      handleClose();
    } catch (error) {
      console.error('Error saving check:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/quality-checks/${id}`);
      fetchChecks();
    } catch (error) {
      console.error('Error deleting check:', error);
    }
  };

  const handleEdit = (check) => {
    setEditCheck(check);
    setFormData({
      order_id: check.order_id,
      parameter: check.parameter,
      value: check.value,
      specification_min: check.specification_min,
      specification_max: check.specification_max,
      passed: check.passed
    });
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditCheck(null);
    setFormData({ order_id: '', parameter: '', value: '', specification_min: '', specification_max: '', passed: true });
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
        Quality Control
        <Button startIcon={<Add />} variant="contained" sx={{ ml: 2 }} onClick={() => setOpen(true)}>
          Add Check
        </Button>
      </Typography>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Parameter</TableCell>
              <TableCell>Value</TableCell>
              <TableCell>Min Spec</TableCell>
              <TableCell>Max Spec</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Checked At</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {(checks || []).map((check) => (
              <TableRow key={check.id}>
                <TableCell>{check.order_id}</TableCell>
                <TableCell>{check.parameter}</TableCell>
                <TableCell>{check.value}</TableCell>
                <TableCell>{check.specification_min}</TableCell>
                <TableCell>{check.specification_max}</TableCell>
                <TableCell>
                  <Chip 
                    label={check.passed ? 'Passed' : 'Failed'} 
                    color={check.passed ? 'success' : 'error'} 
                    size="small" 
                  />
                </TableCell>
                <TableCell>{new Date(check.checked_at).toLocaleString()}</TableCell>
                <TableCell>
                  <IconButton onClick={() => handleEdit(check)}>
                    <Edit />
                  </IconButton>
                  <IconButton onClick={() => handleDelete(check.id)}>
                    <Delete />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
        <DialogTitle>{editCheck ? 'Edit Quality Check' : 'Add Quality Check'}</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            margin="normal"
            label="Order"
            select
            value={formData.order_id}
            onChange={(e) => setFormData({ ...formData, order_id: e.target.value })}
          >
            {orders.map((order) => (
              <MenuItem key={order.id} value={order.id}>
                {order.order_number} - {order.product_code}
              </MenuItem>
            ))}
          </TextField>
          <TextField
            fullWidth
            margin="normal"
            label="Parameter"
            value={formData.parameter}
            onChange={(e) => setFormData({ ...formData, parameter: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Value"
            type="number"
            step="0.01"
            value={formData.value}
            onChange={(e) => setFormData({ ...formData, value: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Min Specification"
            type="number"
            step="0.01"
            value={formData.specification_min}
            onChange={(e) => setFormData({ ...formData, specification_min: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Max Specification"
            type="number"
            step="0.01"
            value={formData.specification_max}
            onChange={(e) => setFormData({ ...formData, specification_max: e.target.value })}
          />
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

export default QualityControl;