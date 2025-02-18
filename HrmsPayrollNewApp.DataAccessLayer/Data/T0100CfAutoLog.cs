using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100CfAutoLog
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LeaveId { get; set; }

    public DateTime? SystemDateTime { get; set; }

    public byte? IsSuccess { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? Comment { get; set; }
}
