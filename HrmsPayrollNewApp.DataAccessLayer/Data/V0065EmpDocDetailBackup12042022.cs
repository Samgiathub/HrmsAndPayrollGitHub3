using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpDocDetailBackup12042022
{
    public string? DocName { get; set; }

    public int RowId { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int CmpId { get; set; }

    public int DocId { get; set; }

    public string DocPath { get; set; } = null!;

    public string DocComments { get; set; } = null!;

    public DateTime? DateOfExpiry { get; set; }
}
