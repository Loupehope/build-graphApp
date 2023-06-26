// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation

public extension BuildStep {

    /// Flattens a group of swift compilations steps.
    ///
    /// When a Swift module is compiled with `whole module` option
    /// The parsed log looks like:
    /// - CompileSwiftTarget
    ///     - CompileSwift
    ///         - CompileSwift file1.swift
    ///         - CompileSwift file2.swift
    /// This tasks removes the intermediate CompileSwift step and moves the substeps
    /// to the root:
    /// - CompileSwiftTarget
    ///     - CompileSwift file1.swift
    ///     - CompileSwift file2.swift
    /// - Returns: The build step with its swift substeps at the root level, and intermediate CompileSwift step removed.
    func moveSwiftStepsToRoot() -> BuildStep {
        var updatedSubSteps = subSteps
        for (index, subStep) in subSteps.enumerated() {
            if subStep.detailStepType == .swiftCompilation && subStep.subSteps.count > 0 {
                updatedSubSteps.remove(at: index)
                updatedSubSteps.append(contentsOf: subStep.subSteps)
            }
        }
        return with(subSteps: updatedSubSteps)
    }
}
