using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999SalaryExportCostDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalExpId { get; set; }

    public decimal? SalExpTrnId { get; set; }

    public decimal CostCenterId { get; set; }

    public decimal Amount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040CostCenter CostCenter { get; set; } = null!;

    public virtual T9999SalaryExport? SalExp { get; set; }

    public virtual T9999SalaryExportDetail? SalExpTrn { get; set; }
}
