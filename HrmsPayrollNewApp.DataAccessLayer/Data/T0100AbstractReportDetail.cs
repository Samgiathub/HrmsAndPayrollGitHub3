using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100AbstractReportDetail
{
    public decimal TransId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ReportId { get; set; }

    public decimal? EmployeeType { get; set; }

    public decimal? SortingNo { get; set; }

    public string? EarningComponentId { get; set; }

    public string? EarningShortName { get; set; }

    public string? DeductionComponentId { get; set; }

    public string? DeductionShortName { get; set; }

    public string? LoanId { get; set; }

    public string? LoanShortName { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? AbstractReportId { get; set; }
}
