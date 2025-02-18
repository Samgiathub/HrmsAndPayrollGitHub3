using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TravelTaxComponentMaster
{
    public decimal TranId { get; set; }

    public string TaxCmponentName { get; set; } = null!;

    public decimal TaxPer { get; set; }

    public string? Remarks { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ModifyDate { get; set; }
}
