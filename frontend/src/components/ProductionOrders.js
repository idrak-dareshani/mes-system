import React, { useState, useEffect } from 'react';
import {
  Container, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Button, Dialog, DialogTitle, DialogContent,
  DialogActions, TextField, MenuItem, IconButton, AppBar, Toolbar
} from '@mui/material';
import { Edit, Delete, Add } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const ProductionOrders = () => {
  const navigate = useNavigate();
  const [orders, setOrders] = useState([]);
  const [open, setOpen] = useState(false);
  const [editOrder, setEditOrder] = useState(null);
  const [formData, setFormData] = useState({
    order_number: '',
    product_code: '',
    quantity: '',
    status: 'pending',
    due_date: ''
  });

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await axios.get('/production-orders/');
      setOrders(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error('Error fetching orders:', error);
      setOrders([]);
    }
  };

  const handleSubmit = async () => {
    try {
      const data = {
        ...formData,
        quantity: parseInt(formData.quantity),
        due_date: new Date(formData.due_date).toISOString()
      };
      
      if (editOrder) {
        await axios.put(`/production-orders/${editOrder.id}`, data);
      } else {
        await axios.post('/production-orders/', data);
      }
      fetchOrders();
      handleClose();
    } catch (error) {
      console.error('Error saving order:', error);
      alert('Error saving order. Please check all fields.');
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/production-orders/${id}`);
      fetchOrders();
    } catch (error) {
      console.error('Error deleting order:', error);
    }
  };

  const handleEdit = (order) => {
    setEditOrder(order);
    setFormData({
      order_number: order.order_number,
      product_code: order.product_code,
      quantity: order.quantity,
      status: order.status,
      due_date: order.due_date.split('T')[0]
    });
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
    setEditOrder(null);
    setFormData({ order_number: '', product_code: '', quantity: '', status: 'pending', due_date: '' });
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
        Production Orders
        <Button startIcon={<Add />} variant="contained" sx={{ ml: 2 }} onClick={() => setOpen(true)}>
          Add Order
        </Button>
      </Typography>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order Number</TableCell>
              <TableCell>Product Code</TableCell>
              <TableCell>Quantity</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Due Date</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {(orders || []).map((order) => (
              <TableRow key={order.id}>
                <TableCell>{order.order_number}</TableCell>
                <TableCell>{order.product_code}</TableCell>
                <TableCell>{order.quantity}</TableCell>
                <TableCell>{order.status}</TableCell>
                <TableCell>{new Date(order.due_date).toLocaleDateString()}</TableCell>
                <TableCell>
                  <IconButton onClick={() => handleEdit(order)}>
                    <Edit />
                  </IconButton>
                  <IconButton onClick={() => handleDelete(order.id)}>
                    <Delete />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
        <DialogTitle>{editOrder ? 'Edit Order' : 'Add Order'}</DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            margin="normal"
            label="Order Number"
            value={formData.order_number}
            onChange={(e) => setFormData({ ...formData, order_number: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Product Code"
            value={formData.product_code}
            onChange={(e) => setFormData({ ...formData, product_code: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Quantity"
            type="number"
            value={formData.quantity}
            onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
          />
          <TextField
            fullWidth
            margin="normal"
            label="Status"
            select
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value })}
          >
            <MenuItem value="pending">Pending</MenuItem>
            <MenuItem value="active">Active</MenuItem>
            <MenuItem value="completed">Completed</MenuItem>
            <MenuItem value="cancelled">Cancelled</MenuItem>
          </TextField>
          <TextField
            fullWidth
            margin="normal"
            label="Due Date"
            type="date"
            value={formData.due_date}
            onChange={(e) => setFormData({ ...formData, due_date: e.target.value })}
            InputLabelProps={{ shrink: true }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose}>Cancel</Button>
          <Button 
            onClick={handleSubmit} 
            variant="contained"
            disabled={!formData.order_number || !formData.product_code || !formData.quantity || !formData.due_date}
          >
            Save
          </Button>
        </DialogActions>
        </Dialog>
      </Container>
    </>
  );
};

export default ProductionOrders;