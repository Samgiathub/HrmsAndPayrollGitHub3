using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040MobilestoreMaster
{
    public decimal StoreId { get; set; }

    public string? CurrentOutletMapping { get; set; }

    public string? StoreCode { get; set; }

    public string? DealerCode { get; set; }

    public string? KroType { get; set; }

    public string? RdsName { get; set; }

    public string? AsmName { get; set; }

    public string? ZsmName { get; set; }

    public decimal? CmpId { get; set; }

    public byte? IsActive { get; set; }
}
