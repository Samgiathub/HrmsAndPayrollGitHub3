using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpInsuranceDetailFamilyMemberBackupMehul02052022
{
    public decimal EmpInsTranId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpDependentId { get; set; }

    public string EmpDependentNameDetail { get; set; } = null!;

    public string EmpDependentMembers { get; set; } = null!;
}
