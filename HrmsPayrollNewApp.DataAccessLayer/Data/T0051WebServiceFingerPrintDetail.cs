using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051WebServiceFingerPrintDetail
{
    public decimal FingerPrintId { get; set; }

    public decimal? EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? CmpId { get; set; }

    public string? FingerPrintfileName { get; set; }

    public int? FingerNumber { get; set; }

    public DateTime? SysDateTime { get; set; }
}
