﻿using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpPrivilegeDetailsBackupMehul07042022
{
    public string FromDate { get; set; } = null!;

    public string PrivilegeId { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string PrivilegeName { get; set; } = null!;

    public string PrivilegeType { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal DeptId { get; set; }

    public decimal TransId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? BandId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? SalDateId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string EmpFirstName { get; set; } = null!;
}
