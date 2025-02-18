using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999SalaryExport
{
    public decimal SalExpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal VchNo { get; set; }

    public string VchType { get; set; } = null!;

    public DateTime VchDate { get; set; }

    public DateTime MonthDate { get; set; }

    public string? VchComments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T9999SalaryExportCostDetail> T9999SalaryExportCostDetails { get; set; } = new List<T9999SalaryExportCostDetail>();

    public virtual ICollection<T9999SalaryExportDetail> T9999SalaryExportDetails { get; set; } = new List<T9999SalaryExportDetail>();
}
