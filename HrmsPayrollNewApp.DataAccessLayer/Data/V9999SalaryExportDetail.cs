using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V9999SalaryExportDetail
{
    public decimal SalExpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SalExpTrnId { get; set; }

    public decimal? EmpId { get; set; }

    public string TallyLedName { get; set; } = null!;

    public decimal DrAmount { get; set; }

    public decimal CrAmount { get; set; }

    public string? Comment { get; set; }

    public decimal? VchNo { get; set; }

    public string? VchType { get; set; }

    public DateTime? VchDate { get; set; }

    public DateTime? MonthDate { get; set; }

    public string? VchComments { get; set; }
}
