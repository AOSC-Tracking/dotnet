﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Composition;
using Microsoft.CodeAnalysis.Host.Mef;
using Microsoft.CodeAnalysis.LanguageServer.Handler;
using Microsoft.CodeAnalysis.LanguageServer.Handler.DebugConfiguration;
using Microsoft.CodeAnalysis.PooledObjects;
using Roslyn.Utilities;

namespace Microsoft.CodeAnalysis.LanguageServer;

/// <summary>
/// Handler that allows the client to retrieve a set of restorable projects.
/// Used to populate a list of projects that can be restored.
/// </summary>
[ExportCSharpVisualBasicStatelessLspService(typeof(RestorableProjectsHandler)), Shared]
[Method(MethodName)]
[method: ImportingConstructor]
[method: Obsolete(MefConstruction.ImportingConstructorMessage, error: true)]
internal sealed class RestorableProjectsHandler(ProjectTargetFrameworkManager projectTargetFrameworkManager) : ILspServiceRequestHandler<string[]>
{
    internal const string MethodName = "workspace/_roslyn_restorableProjects";

    public bool MutatesSolutionState => false;

    public bool RequiresLSPSolution => true;

    public Task<string[]> HandleRequestAsync(RequestContext context, CancellationToken cancellationToken)
    {
        Contract.ThrowIfNull(context.Solution);

        using var _ = ArrayBuilder<string>.GetInstance(out var projectsBuilder);
        foreach (var project in context.Solution.Projects)
        {
            // To restore via the dotnet CLI, we must have a file path and it must be a .NET core project.
            if (project.FilePath != null && projectTargetFrameworkManager.IsDotnetCoreProject(project.Id))
            {
                projectsBuilder.Add(project.FilePath);
            }
        }

        // We may have multiple projects with the same file path in multi-targeting scenarios.
        // They'll all get restored together so we only want one result per project file.
        projectsBuilder.RemoveDuplicates();

        // Ensure the client gets a consistent ordering.
        projectsBuilder.Sort(StringComparer.OrdinalIgnoreCase);

        return Task.FromResult(projectsBuilder.ToArray());
    }
}
