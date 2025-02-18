using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0501SalesErrorLog
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RowId { get; set; }

    public string? ErrorCode { get; set; }

    public string? ErrorDesc { get; set; }

    public DateTime? ForDate { get; set; }

    public string? ImportType { get; set; }

    public string? KeyGuid { get; set; }
}
