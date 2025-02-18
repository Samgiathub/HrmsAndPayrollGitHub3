using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpReportingDetailClone
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal REmpId { get; set; }

    public decimal CmpId { get; set; }

    public string ReportingTo { get; set; } = null!;

    public string ReportingMethod { get; set; } = null!;

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
