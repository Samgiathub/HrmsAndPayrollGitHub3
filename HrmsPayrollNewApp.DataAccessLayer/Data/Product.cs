using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Product
{
    public int Id { get; set; }

    public string? ProductName { get; set; }

    public decimal? Price { get; set; }
}
