using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EventLog
{
    public decimal LogId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string? ModuleName { get; set; }

    public string? ErrorName { get; set; }

    public string? Description { get; set; }

    public DateTime SystemDate { get; set; }

    public byte EventFlag { get; set; }

    public string? Remarks { get; set; }
}
