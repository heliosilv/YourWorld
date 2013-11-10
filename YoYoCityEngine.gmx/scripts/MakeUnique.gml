/// Make a block "unique" so that we can alter faces/tyextures/flags etc and return the block_info index
/// x = argument0
/// y = argument1
/// z = argument2
var _x=argument0;
var _y=argument1;
var _z=argument2;

// Cant make this one unique?
if( _x<0 || x>=MapWidth || _y<0 || y>=MapWidth ) return -1;

// Get the length of the block list (if we need another one, it goes on the end)
var column = ds_grid_get(Map,_x,_y);

// First, check to see if we need to expand the array to include the requested _Z
var len = array_length_1d( column );
if( (len-1)<_z ){
    // if we have to expand the array, then the requested block will point to 
    // "cube" 0, which will have more than one ref, so it'll fall through into the 
    // make unique part, and so the array will THEN be written into the grid.
    for(var i=len;i<=_z;i++){
        column[i]=0;           // fill with block "0"
        IncRef(0);
    }
}


var oldblock = column[_z];

// If only THIS block points here, then just modify it directly.
if( GetRef(oldblock)==1 ) return oldblock;

// First, do we have any "spare" blocks on the free list?
var NewBlock =  ds_list_size(block_info);
if( ds_stack_size(FreeList)!=0 ){
    NewBlock=ds_stack_pop(FreeList);            // if so, use that first
}
column[_z] = NewBlock;
ds_grid_set(Map,_x,_y,column);

// Copy all the details of the OLD block
OldInfo = ds_list_find_value( block_info, oldblock );

var info = 0;
var size = array_length_1d(OldInfo);
for(var i=0;i<size;i++){
    info[i]=OldInfo[i];    
}

// Add the new block to the end of the block_info list
ds_list_add( block_info,info );
AddRef(1);
return NewBlock;

