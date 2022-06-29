template<typename T>
class vector
{
   int _size;
public:
   T _vec[];
   
   /* Constructors */
   vector():_size(0){}
   vector(int _sz);
   vector(int _sz, T& _fill);
   vector(vector<T>& __b);
   /* End of Constructors */
   
   int size();
   T operator[](int i);
   void at(int i, T& new_val);
   void push_back(T& val);
   T back();
   T pop_back();
   void sort();
   void sort(int l, int r);
   int lower_bound(T& __x);
   int lower_bound(int l, int r, T& __x);
   int upper_bound(T& __x);
   int upper_bound(int l, int r, T& __x);
   void erase(int it);
};

template<typename T>
vector::vector(int _sz)
{
   ArrayResize(_vec, _sz);
   _size = _sz;
}

template<typename T>
vector::vector(int _sz, T& _fill)
{
   ArrayResize(_vec, _sz);
   for(int i = 0; i < _sz; i++) _vec[i] = _fill;
   _size = _sz;
}

template<typename T>
vector::vector(vector<T>& __b)
{
   ArrayResize(_vec, __b.size());
   for(int i = 0; i < __b.size(); i++) _vec[i] = __b[i];
   _size = __b.size();
}

template<typename T>
int vector::size()
{
  return this._size;
}
   
template<typename T>
T vector::operator[](int i)
{
   if(this._size == 0 || i >= this._size) return T(-1);
   return _vec[i];
}
   
template<typename T>
void vector::at(int i, T& new_val)
{
  if(i >= this._size) 
  {
     ArrayResize(_vec, i+1);
     this._size = i+1;
  }
  _vec[i] = new_val;
}

template<typename T>
void vector::push_back(T& val)
{
  this._size++;
  ArrayResize(_vec, this._size);
  _vec[this._size-1] = val;
}

template<typename T>   
T vector::back()
{
  if(this._size == 0) return T(-1);
  return _vec[this._size-1];
}
   
template<typename T>
T vector::pop_back()
{
  if(this._size == 0) return T(-1);
  T ret = back();
  ArrayResize(_vec, --this._size);
  return ret;
}
   
template<typename T>
void vector::sort()
{
  sort(0, this._size-1);
}
   
template<typename T>
void vector::sort(int l, int r)
{
   if(l >= r) return;
   sort(l, (l+r)/2);
   sort((l+r)/2+1, r);  
   vector<T> __b;
   int l1 = l, l2 = (l+r)/2+1;
   while(l1 <= (l+r)/2 && l2 <= r)
   {
      if(_vec[l1] < _vec[l2]) __b.push_back(_vec[l1++]);
      else __b.push_back(_vec[l2++]);
   }
   while(l1 <= (l+r)/2) __b.push_back(_vec[l1++]);
   while(l2 <= r) __b.push_back(_vec[l2++]);
  
   for(int i = r; i >= l; i--) _vec[i] = __b.pop_back();
}
   
template<typename T>
int vector::lower_bound(T& __x)
{
    return lower_bound(0, this._size-1, __x);
}
    
template<typename T>
int vector::lower_bound(int l, int r, T& __x)
{
    if(_vec[r] < __x) return r+1;

    int __cur = l-1;
    for(int i = 30; i >= 0; i--)
    {
        if(__cur + (1<<i) > r) continue;
        __cur += 1<<i;
        if(_vec[__cur] >= __x) __cur -= 1<<i;
    }
    return __cur+1;
}

template<typename T>   
int vector::upper_bound(T& __x)
{
    return upper_bound(0, this._size-1, __x);
}
    
template<typename T>
int vector::upper_bound(int l, int r, T& __x)
{
    if(_vec[r] <= __x) return r+1;

    int __cur = l-1;
    for(int i = 30; i >= 0; i--)
    {
        if(__cur + (1<<i) > r) continue;
        __cur += 1<<i;
        if(_vec[__cur] > __x) __cur -= 1<<i;
    }
    return __cur+1;
}

template<typename T>
void vector::erase(int _it)
{
   if(_it < 0 || _it >= _size) return;
   for(int _ind = _it; _ind+1 < _size; _ind++)
   {
      _vec[_ind] = _vec[_ind+1];
   }
   ArrayResize(_vec, _size-1);
   _size--;
}
