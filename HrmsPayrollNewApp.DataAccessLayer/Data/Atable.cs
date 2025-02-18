using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Atable
{
    public string? CustomerId { get; set; }

    public DateOnly? SaleDate { get; set; }

    public int? SaleValue { get; set; }
}
