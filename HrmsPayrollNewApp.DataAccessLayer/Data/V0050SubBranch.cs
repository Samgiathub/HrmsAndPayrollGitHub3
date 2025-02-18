using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050SubBranch
{
    public decimal? CmpId { get; set; }

    public decimal SubBranchId { get; set; }

    public decimal? BranchId { get; set; }

    public string? SubBranchCode { get; set; }

    public string? SubBranchName { get; set; }

    public string? SubBranchDescription { get; set; }

    public string? BranchName { get; set; }

    public string? CityName { get; set; }

    public byte? IsActive { get; set; }

    public string StatusColor { get; set; } = null!;
}
