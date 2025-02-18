using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ColumnMaster
{
    public decimal ColumnId { get; set; }

    public string ColumnValue { get; set; } = null!;

    public string ColumnName { get; set; } = null!;
}
