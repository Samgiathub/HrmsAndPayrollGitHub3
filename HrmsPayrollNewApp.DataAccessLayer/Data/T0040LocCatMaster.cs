using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LocCatMaster
{
    public decimal LocCatId { get; set; }

    public string CategoryName { get; set; } = null!;

    public string? Remarks { get; set; }
}
