using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100GeneralAutoLog
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string ModuleName { get; set; } = null!;

    public byte? IsSuccess { get; set; }

    public string? Comment { get; set; }

    public DateTime? SystemDateTime { get; set; }
}
