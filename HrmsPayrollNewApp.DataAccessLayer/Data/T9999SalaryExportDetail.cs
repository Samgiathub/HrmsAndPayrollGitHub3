using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999SalaryExportDetail
{
    public decimal SalExpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SalExpTrnId { get; set; }

    public decimal? EmpId { get; set; }

    public string TallyLedName { get; set; } = null!;

    public decimal DrAmount { get; set; }

    public decimal CrAmount { get; set; }

    public string? Comment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T9999SalaryExport SalExp { get; set; } = null!;

    public virtual ICollection<T9999SalaryExportCostDetail> T9999SalaryExportCostDetails { get; set; } = new List<T9999SalaryExportCostDetail>();
}
