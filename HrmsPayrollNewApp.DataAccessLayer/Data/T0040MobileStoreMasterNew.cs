using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MobileStoreMasterNew
{
    public decimal StoreId { get; set; }

    public decimal? CmpId { get; set; }

    public string? EmpCode { get; set; }

    public string? CurrentOutletMapping { get; set; }

    public string? StoreCode { get; set; }

    public string? DealerCode { get; set; }

    public string? KroType { get; set; }

    public string? RdsName { get; set; }

    public string? AsmName { get; set; }

    public string? ZsmName { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }

    public byte? IsActive { get; set; }

    public decimal? EmpId { get; set; }
}
