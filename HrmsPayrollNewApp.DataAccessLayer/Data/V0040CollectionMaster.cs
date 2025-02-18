using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040CollectionMaster
{
    public decimal CollectionId { get; set; }

    public string? CollectionMonth { get; set; }

    public decimal? CollectionYear { get; set; }

    public decimal? ManagerId { get; set; }

    public decimal? CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string EmpName { get; set; } = null!;
}
