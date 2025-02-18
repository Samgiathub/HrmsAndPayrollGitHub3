using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V9999SalaryExportCostDetail
{
    public string CostCategory { get; set; } = null!;

    public string CostCenter { get; set; } = null!;

    public decimal VchNo { get; set; }

    public string VchType { get; set; } = null!;

    public decimal? SalExpId { get; set; }

    public decimal? SalExpTrnId { get; set; }

    public decimal CostCenterId { get; set; }

    public decimal Amount { get; set; }

    public decimal TallyCatId { get; set; }
}
