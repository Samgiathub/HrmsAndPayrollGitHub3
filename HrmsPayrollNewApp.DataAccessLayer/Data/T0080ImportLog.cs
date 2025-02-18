using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080ImportLog
{
    public decimal ImId { get; set; }

    public decimal RowNo { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpCode { get; set; }

    public string? ErrorDesc { get; set; }

    public string? ActualValue { get; set; }

    public string? Suggestion { get; set; }

    public DateTime? ForDate { get; set; }

    public string? ImportType { get; set; }

    public string? KeyGuid { get; set; }
}
